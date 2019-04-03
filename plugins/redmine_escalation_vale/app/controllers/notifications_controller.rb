class NotificationsController < ApplicationController
  unloadable

  before_filter :require_admin
  OWN_SELF="Atribuído Para"

  def is_filtering_owner (value)
    value.include? OWN_SELF
  end

  def get_visibility_report_grouped_by_rules
    resources = []
    rules = Rule.all
    rules.each do |rule|
      sql = " 1=1 "
      level = ""
      if is_filtering_owner(rule.hierarchy)
        level = " visibility_reports.user_id "
      else
        level = (rule.hierarchy.dup.sub! "DE-","n")+"_id"
        sql += " and hierarchies.level is not null and hierarchy_id is not null "
      end
      if rule.classification.present?
        sql += " and classification = '#{rule.classification}' "
      end
      if rule.area.present?
        sql += " and area = '#{rule.area}' "
      end
      if rule.min_sent.present?
        sql += " and sent_number >= '#{rule.min_sent}' "
      end
      if rule.max_sent.present?
        sql += " and sent_number < '#{rule.max_sent}' "
      end
      reports = VisibilityReport
        .where(sql + " and visibility_reports.user_id is not null")
        .joins('LEFT OUTER JOIN "hierarchies" ON "hierarchies"."user_id" = "visibility_reports"."user_id"')
        .group("#{level}")
        .where("#{level} is not null")
        .select("#{level} as user_id , string_agg(visibility_reports.issue_id::text, ',') as issues
                , '#{rule.id}' as rule_id,'#{rule.area}' as area, '#{rule.hierarchy}' as hierarchy
                , '#{rule.classification}' as classification, '#{rule.min_sent}' as min_sent
                , '#{rule.max_sent}' as max_sent , count(visibility_reports.issue_id) qt")
      resources.push(*reports.map(&:attributes))
    end
    resources = resources.sort_by{ |rsr| rsr["qt"]}.reverse!
    resources.each do |resource|
      resource['bccs'] = get_bccs(resource['issues'], Rule.find(resource["rule_id"])).map{|u| User.find_by_id(u).mail}
      resource['bccs_id'] = get_bccs(resource['issues'], Rule.find(resource["rule_id"]))
    end
    resources
  end

  def get_bccs(issues, rule)
    bccs = []
    if is_filtering_owner(rule.hierarchy)
      users = issues.split(",").map{|i| VisibilityReport.where(:issue_id => i).select("user_id").map(&:attributes)}.flatten
      bccs = users.flatten.map{|u| User.find_by_id(u["user_id"]).id}
    else
      level_id = (rule.hierarchy.dup.sub! "DE-","")
      hierarchies = issues.split(",").map{|i| VisibilityReport.where(:issue_id => i).where("level is not null").joins(:hierarchy).select("hierarchies.*").map(&:attributes)}.flatten
      hierarchies.each do |hierarchy|
        range = *(level_id.to_i..hierarchy["level"])
        bccs.push(*range.map{|num| User.find_by_id(hierarchy["n"+num.to_s+"_id"]).try(:id)})
      end
    end
    bccs.uniq
  end

  def decode_filter
    decoded = []
    if params[:filter].present?
      decoded = Base64.decode64(params[:filter])
      if decoded.include? ","
        decoded = decoded.split(",")
      end
    end
    decoded
  end

  def index
    @filter = decode_filter
    @resources = get_visibility_report_grouped_by_rules
  end

  def sender
    @filter = decode_filter
    @resources = get_visibility_report_grouped_by_rules.reject{|r| (@filter.include? r["user_id"].to_s)}
    @resources.each do |resource|
      if resource["user_id"] != nil
        rule = Rule.find(resource["rule_id"])
        email_template = EmailTemplate.find(rule.email_template)
        is_own = is_filtering_owner(Rule.find(resource["rule_id"]).hierarchy)
        NotificationsController::EscalationsMailer.default_mail(resource,email_template, is_own).deliver
      end
    end
  end

  class EscalationsMailer < ActionMailer::Base
    include ApplicationHelper
    default from: Setting.mail_from
    layout 'mailer'

    def increment_sent_number(resources)
      resources.map {|r|
        r.sent_number = r.sent_number + 1
        r.save
      }
    end

    def default_mail(visibility_report,email_template, is_own)
      @template = textilizable(email_template.template)
      @image_url = email_template.image_url
      @level = Rule.find(visibility_report["rule_id"]).hierarchy
      @is_own = is_own
      @resources = visibility_report["issues"].split(",").map{ |i| VisibilityReport.where(:issue_id =>i).first}
      increment_sent_number(@resources)
      @resources = @resources.sort_by{ |a| [a.sent_number, a.phase_aging]}.reverse!
      if Setting.bcc_recipients?
        mail subject: email_template.subject, bcc: visibility_report['bccs']
      else
        mail subject: email_template.subject, cc: visibility_report['bccs']
      end

    end
  end

end
