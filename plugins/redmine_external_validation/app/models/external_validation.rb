class ExternalValidation < ActiveRecord::Base
  unloadable

  scope :find_by_issue, lambda { |issue|
    where('(project_id     = ? or all_projects    = true)', issue.project_id).
    where('(tracker_id     = ? or all_trackers    = true)', issue.tracker_id).
    where('(status_from_id = ? or (status_from_id is NULL and ? is NULL) or all_status_from = true)', issue.status_id_was, issue.status_id_was).
    where(status_to_id: issue.status_id)
  }

  belongs_to :project
  belongs_to :tracker
  belongs_to :status_from     , class_name: 'IssueStatus'
  belongs_to :status_to       , class_name: 'IssueStatus'
  belongs_to :not_found_status, class_name: 'IssueStatus'

  belongs_to :message_custom_field, class_name: 'IssueCustomField'

  belongs_to :success_status, class_name: 'IssueStatus'

  has_many :external_validation_queries, dependent: :destroy
  accepts_nested_attributes_for :external_validation_queries, reject_if: :all_blank, allow_destroy: true

  has_many :external_validation_roles, -> { ordered }, dependent: :destroy
  accepts_nested_attributes_for :external_validation_roles, reject_if: :all_blank, allow_destroy: true

  # NÂO FUNCIONA POR MAIS DE UM GRID
  def queries(issue)
    grid_queries   = external_validation_queries.joins(:custom_field).where(custom_fields: {field_format: 'grid'}).group_by(&:custom_field_id)
    normal_queries = external_validation_queries.joins(:custom_field).where('custom_fields.field_format != ?', 'grid').map { |nq| [nq.field_name, issue.custom_field_value(nq.custom_field_id)] }.to_h

    ret = grid_queries.keys.map do |k|
      external_queries = grid_queries[k]

      JSON.parse(issue.custom_value_for(k).value.gsub("=>", ":")).values.map do |row|
        external_queries.map { |eq| [eq.field_name, row[eq.column_grid_id.to_s] ] }.to_h.merge(normal_queries)
      end
    end.first

    ret.blank? ? [normal_queries] : ret
  end

  # NÂO FUNCIONA POR MAIS DE UM GRID
  def queries_with_column_grid_id(issue)
    grid_queries   = external_validation_queries.joins(:custom_field).where(custom_fields: {field_format: 'grid'}).group_by(&:custom_field_id)
    normal_queries = external_validation_queries.joins(:custom_field).where('custom_fields.field_format != ?', 'grid').map { |nq| [nq.custom_field_id, issue.custom_field_value(nq.custom_field_id)] }.to_h

    ret = grid_queries.keys.map do |k|
      external_queries = grid_queries[k]

      JSON.parse(issue.custom_value_for(k).value.gsub("=>", ":")).values.map do |row|
        external_queries.map { |eq| [eq.column_grid_id, row[eq.column_grid_id.to_s] ] }.to_h.merge(normal_queries)
      end
    end.first

    ret.blank? ? [normal_queries] : ret
  end

  def perform(user_id, issue_id, external_validation_id, retry_num)
    user  = User.find(user_id)
    issue = Issue.find(issue_id)

    return if issue.status_id != status_to_id

    begin
      validations = ExternalValidationResource.validations(self, issue)
    rescue Net::ReadTimeout
      reschedule_async_validation(external_validation_id, issue_id, retry_num, user_id)
      return true
    end

    error_status = nil

    message_custom_fields = {}

    validations.select { |validation| validation.values.first.blank? }.each do |validation|
      if Setting.plugin_redmine_external_validation['retry_num'] && Setting.plugin_redmine_external_validation['retry_num'].to_i > retry_num
        reschedule_async_validation(external_validation_id, issue_id, retry_num, user_id)
        return true
      else
        error_status ||= not_found_status

        message_custom_fields = {
          message_custom_field_id => "* #{not_found_message}\n"
        }
      end
    end

    if error_status
      issue.init_journal(user, '')
      issue.custom_field_values = message_custom_fields
      issue.status = error_status
    else
      wrong_rules = []
      errors_found = []

      validations.each do |query_validation|
        external_validation_roles.each do |rule|
          valid = validate_rule(rule, query_validation, issue)

          status = deal_with_rule(valid, rule, wrong_rules, query_validation)

          error_status ||= status
        end
      end

      issue.init_journal(user, '')

      if error_status
        get_notes(wrong_rules, message_custom_fields)
        errors_found |= get_errors(wrong_rules)

        issue.status = error_status
        issue.custom_field_values = { errors_custom_field_id => errors_found }.merge(message_custom_fields)
      else
        issue.status = success_status
        issue.custom_field_values = { errors_custom_field_id => [] }
      end
    end

    issue.save(validate: false)
  end

  def reschedule_async_validation(external_validation_id, issue_id, retry_num, user_id)
    AsyncExternalValidation.set(wait_until: Time.zone.now + Setting.plugin_redmine_external_validation['retry_after'].to_i.seconds).perform_later(user_id, issue_id, external_validation_id, retry_num + 1)
  end

  private

  def get_notes(rules, message_custom_fields)
    rules.uniq { |r| r[0] }.each do |rule|
      message_custom_fields[rule[0].message_custom_field_id] ||= ''
      message_custom_fields[rule[0].message_custom_field_id] << "* #{parse_message(rule[0].error_message, rule[1])}\n"
    end
  end

  def parse_message(message, validation_value)
    message.gsub('${validation_value}', validation_value.to_s)
  end

  def get_errors(rules)
    rules.map { |r| r[0] }.uniq.map(&:error_id)
  end

  def validate_rule(rule, validation, issue)
    if rule.constant?
      rule.compare_with_constant(validation.values.first[rule.field_name])
    elsif !rule.secondary_custom_field_id.blank?
      rule.compare_with_custom_field(issue.custom_value_for(rule.custom_field_id),
                                     issue.custom_value_for(rule.secondary_custom_field_id))
    else
      rule.compare_with_format(issue.custom_value_for(rule.custom_field_id), validation, rule.field_name, rule.column_grid_id)
    end
  end

  def deal_with_rule(valid, rule, wrong_rules, validation)
    return if valid

    wrong_rules << [rule, validation.values.first[rule.field_name]]
    rule.error_status
  end
end
