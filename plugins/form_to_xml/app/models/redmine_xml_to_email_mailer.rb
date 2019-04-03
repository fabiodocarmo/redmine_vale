class RedmineXmlToEmailMailer < ActionMailer::Base

  def mail(headers={}, &block)
    headers.reverse_merge! 'X-Mailer' => 'Redmine',
            'X-Redmine-Host' => Setting.host_name,
            'X-Redmine-Site' => Setting.app_title,
            'X-Auto-Response-Suppress' => 'All',
            'Auto-Submitted' => 'auto-generated',
            'From' => Setting.plugin_form_to_xml['sender_email'],
            'List-Id' => "<#{Setting.plugin_form_to_xml['sender_email'].to_s.gsub('@', '.')}>"

    if @message_id_object
      headers[:message_id] = "<#{self.class.message_id_for(@message_id_object)}>"
    end
    if @references_objects
      headers[:references] = @references_objects.collect {|o| "<#{self.class.references_for(o)}>"}.join(' ')
    end

    m = if block_given?
      super headers, &block
    else
      super headers do |format|
        format.text
        format.html unless Setting.plain_text_mail?
      end
    end

    m
  end

  def notify_external(issue, xml)
    email_config = load_configuration

    if email_config.present?
      delivery_method = email_config['delivery_method']
      delivery_options = email_config['smtp_settings']

      delivery_options && delivery_options.symbolize_keys!
    else
      delivery_method, delivery_options = nil, nil
    end

    attachments[xml.filename] = File.read(xml.diskfile)

    if issue.tracker_id.to_s.in?Setting.plugin_form_to_xml["transport_converter_issues"]

      mail_settings = {
          to: Setting.plugin_form_to_xml["transport_notify_email"],
          subject: "#{issue.custom_values.find_by_custom_field_id(Setting.plugin_form_to_xml["transport_title"]).value}"
      }

    else
      mail_settings = {
          to: Setting.plugin_form_to_xml["notify_email"],
          subject: "#{issue.custom_values.find_by_custom_field_id(Setting.plugin_form_to_xml["nf_rf"]).value}"
      }
    end
    if delivery_method.present? && delivery_options.present?
      mail_settings.merge!(
          delivery_method: delivery_method,
          delivery_method_options: delivery_options
      )
    end

    mail mail_settings
  end

  def load_configuration
    filename = File.join(Rails.root, 'config', 'configuration.yml')
    if File.exist? filename
      configuration = Redmine::Configuration.send(:load_from_yaml, filename, 'grc')
      if configuration.is_a? Hash
        return (configuration['email_delivery'] || {})
      else
        return {}
      end
    else
      {}
    end
  end
end
