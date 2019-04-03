# frozen_string_literal: true

class EmailToNfJob < ExecJob
  unloadable

  def perform_mail(mail)
    issue = build_new_issue(mail)

    fill_attachments(mail, issue)

    email = mail.from[0]

    fill_author(issue, email)
    fill_description(issue, mail)

    save_issue(issue, email)
  end

  def build_new_issue(mail)
    Issue.new(subject: mail.subject,
        project_id: config[:project],
        tracker_id: config[:tracker])
  end

  def fill_attachments(mail, issue)
    mail.attachments.each do |attachment|
      if attachment.content_type =~ /xml/
        fill_xml_data(issue, attachment)
      elsif attachment.content_type =~ /pdf/
        fill_pdf_data(issue, attachment)
      end
    end
  end

  def fill_xml_data(issue, attachment)
    xml = attachment.decoded
    xml_hash = XmlToHashService.convert(xml)

    issue.custom_field_values = xml_hash.merge(
      config[:xml_custom_field] => attachment
    )
  end

  def fill_pdf_data(issue, attachment)
    issue.custom_field_values = {
      config[:pdf_custom_field] => attachment
    }
  end

  def fill_author(issue, email)
    issue.author = User.find_by_mail(email) || AnonymousUser.first
  end

  def fill_description(issue, mail)
    issue.description = mail.body.raw_source
  end

  def save_issue(issue, email)
    if issue.save(validate: !config[:always_save].to_bool)
      EmailToNfMailer.notify_receipt(email, issue).deliver
    else
      EmailToNfMailer.notify_failed_receipt(email, issue).deliver
    end
  end

  def self.schema
    {
      project: project_schema,
      tracker: tracker_schema,
      pdf_custom_field: pdf_custom_field_schema,
      xml_custom_field: xml_custom_field_schema,
      require_xml: require_xml_schema,
      always_save: always_save_schema,
    }
  end

  private_class_method

  def self.project_schema
    {
      field_type: :collection,
      model: 'Project',
      key: :name,
      include_blank: true
    }
  end

  def self.tracker_schema
    {
      field_type: :collection,
      model: 'Tracker',
      key: :name,
      include_blank: true
    }
  end

  def self.pdf_custom_field_schema
    {
      field_type: :collection,
      model: 'IssueCustomField',
      key: :name,
      include_blank: true
    }
  end

  def self.xml_custom_field_schema
    {
      field_type: :collection,
      model: 'IssueCustomField',
      key: :name,
      include_blank: true
    }
  end

  def self.require_xml_schema
    {
      field_type: :boolean
    }
  end

  def self.always_save_schema
    {
      field_type: :boolean
    }
  end
end
