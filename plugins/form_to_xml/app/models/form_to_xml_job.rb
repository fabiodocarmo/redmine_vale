class FormToXmlJob < ExecJob
  unloadable

  def perform(issue_id)
    issue = issue.is_a?(Issue) ? issue.reload : Issue.find(issue_id)
    Rails.logger.info(issue.inspect)

    attachment = get_attachment(issue)

    custom_value = issue.custom_values.find_by_custom_field_id(Setting.plugin_form_to_xml["file_field"])
    custom_value.value = attachment
    custom_value.save!
  end

  def get_attachment(issue)
    attachment              = Attachment.new(:file => get_tempfile(issue))
    attachment.author       = issue.author
    attachment.filename     = Redmine::Utils.random_hex(16) + '.xml'
    attachment.content_type = "application/xml"
    attachment.save
    attachment
  end

  def get_tempfile(issue)
    out = Tempfile.new(Redmine::Utils.random_hex(16) + '.xml')
    out << to_xml(issue)
    out.rewind
    out
  end

  def to_xml(issue)
    if issue.tracker_id.to_s.in?Setting.plugin_form_to_xml["transport_converter_issues"]
      converted_xml = Setting.plugin_form_to_xml["transport_xml_format"]
    else
      converted_xml = Setting.plugin_form_to_xml["xml_format"]
    end

    converted_xml.gsub(/\#\{([\w|\:|\%|\"]+)\}/) do |expression|
      custom_field = expression.match(/\#\{([\w|\:|\%|\"]+)\}/) { $1.split(':')[0] }
      custom_field.match(/custom_field_(\d+)/) {
        custom_field_value(issue, $1, expression.match(/\#\{([\w|\:|\%|\"]+)\}/) { $1.split(':')[1..-1].join(':') })
      } || expression
    end
  end

  def custom_field_value(issue, custom_field_id, cf_format)
    value = issue.custom_field_value(custom_field_id)
    if value && !cf_format.blank?
      cf_format_type    = cf_format.split(':')[0]
      cf_format_partner = cf_format.split(':')[1..-1].join(':').gsub('"','')
      unless cf_format_partner.blank?
        case cf_format_type
        when "date"
          value = DateTime.parse(value).strftime(cf_format_partner)
        when "decimal"
          value = value.to_f.round(cf_format_partner.to_i).to_s
        end
      end
    end

    value.encode(:xml => :text)
  end
end
