module GestorChamadas
  # Patches Redmine's Issues Controller dynamically.  Adds a +after_save+ filter.
  module HelpdeskMailerPatch
    def self.included(base) # :nodoc
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in developmen
        class << self
          alias_method_chain :apply_macro, :apply_macro_patch
        end
      end
    end

    module ClassMethods
      def get_sla_text(issue)
        sla = Sla.where(project_id: issue.project.id, tracker_id: issue.tracker.id).first

        return '' unless sla

        if sla.prazo.length == 5
          "#{sla.prazo[0..1]}" +  l(:hours_label) "#{sla.prazo[3..4]}" + l(:minutes_label)
        else
          "#{sla.prazo[0..2]}" l(:hours_label) "#{sla.prazo[4..5]}" + l(:minutes_label)
        end
      end

      def get_faq_links(issue)
        faqs = FaqLink.where(tracker_id: issue.tracker.id)
        ret = ''

        return ret if faqs.empty?

        faqs.each do |faq|
          ret << "FAQ: #{faq.faq_link}\n"
        end

        ret
      end

      def apply_macro_with_apply_macro_patch(text, contact, issue, journal_user=nil)
        return '' if text.blank?

        text = text.gsub(/%%NAME%%|\{%contact.first_name%\}/, contact.first_name)
        text = text.gsub(/%%FULL_NAME%%|\{%contact.name%\}/, contact.name)
        text = text.gsub(/%%COMPANY%%|\{%contact.company%\}/, contact.company) if contact.company
        text = text.gsub(/%%LAST_NAME%%|\{%contact.last_name%\}/, contact.last_name.blank? ? "" : contact.last_name)
        text = text.gsub(/%%MIDDLE_NAME%%|\{%contact.middle_name%\}/, contact.middle_name.blank? ? "" : contact.middle_name)
        text = text.gsub(/\{%contact.email%\}/, contact.primary_email.to_s)
        text = text.gsub(/%%DATE%%|\{%date%\}/, ApplicationHelper.format_date(Date.today))
        text = text.gsub(/%%ASSIGNEE%%|\{%ticket.assigned_to%\}/, issue.assigned_to.blank? ? "" : issue.assigned_to.name)
        text = text.gsub(/%%ISSUE_ID%%|\{%ticket.id%\}/, issue.id.to_s) if issue.id
        text = text.gsub(/%%ISSUE_TRACKER%%|\{%ticket.tracker%\}/, issue.tracker.name) if issue.tracker
        text = text.gsub(/%%QUOTED_ISSUE_DESCRIPTION%%|\{%ticket.quoted_description%\}/, issue.description.gsub(/^/, "> ")) if issue.description
        text = text.gsub(/%%PROJECT%%|\{%ticket.project%\}/, issue.project.name) if issue.project
        text = text.gsub(/%%SUBJECT%%|\{%ticket.subject%\}/, issue.subject) if issue.subject
        text = text.gsub(/%%NOTE_AUTHOR%%|\{%response.author%\}/, journal_user.name) if journal_user
        text = text.gsub(/%%NOTE_AUTHOR.FIRST_NAME%%|\{%response.author.first_name%\}/, journal_user.firstname) if journal_user
        text = text.gsub(/\{%ticket.status%\}/, issue.status.name) if issue.status
        text = text.gsub(/\{%ticket.priority%\}/, issue.priority.name) if issue.priority
        text = text.gsub(/\{%ticket.estimated_hours%\}/, issue.estimated_hours.to_s) if issue.estimated_hours
        text = text.gsub(/\{%ticket.done_ratio%\}/, issue.done_ratio.to_s) if issue.done_ratio
        text = text.gsub(/\{%ticket.closed_on%\}/, ApplicationHelper.format_date(issue.closed_on)) if issue.respond_to?(:closed_on) && issue.closed_on
        text = text.gsub(/\{%ticket.due_date%\}/, ApplicationHelper.format_date(issue.due_date)) if issue.due_date
        text = text.gsub(/\{%ticket.start_date%\}/, ApplicationHelper.format_date(issue.start_date)) if issue.start_date
        text = text.gsub(/\{%ticket.public_url%\}/, Setting.protocol + '://' + Setting.host_name + Rails.application.routes.url_helpers.public_ticket_path(issue.helpdesk_ticket.id, issue.helpdesk_ticket.token) ) if text.match(/\{%ticket.public_url%\}/) &&  issue.helpdesk_ticket

        text = text.gsub(/\{%ticket.confirmation_url%\}/, Setting.protocol + '://' + Setting.host_name + Rails.application.routes.url_helpers.gestor_chamados_confirmation_ticket_path(issue.helpdesk_ticket.id, issue.helpdesk_ticket.token) ) if text.match(/\{%ticket.confirmation_url%\}/) && issue.helpdesk_ticket
        text = text.gsub(/\{%sla%\}/, get_sla_text(issue)) if text.match(/\{%sla%\}/)
        text = text.gsub(/\{%faq_links%\}/, get_faq_links(issue)) if text.match(/\{%faq_links%\}/)

        if text =~ /\{%ticket.history%\}/
          ticket_history = ''
          issue.journals.includes(:journal_message).map(&:journal_message).compact.each do |journal_message|
            message_author = "*#{l(:label_crm_added_by)} #{journal_message.is_incoming? ? journal_message.from_address : journal_message.journal.user.name}, #{format_time(journal_message.message_date)}*"
            ticket_history = (message_author + "\n" + journal_message.journal.notes + "\n" + ticket_history).gsub(/^/, "> ")
          end
          text = text.gsub(/\{%ticket.history%\}/, ticket_history)
        end

        issue.custom_field_values.each do |value|
          text = text.gsub(/%%#{value.custom_field.name}%%/, value.value.to_s)
        end

        contact.custom_field_values.each do |value|
          text = text.gsub(/%%#{value.custom_field.name}%%/, value.value.to_s)
        end if contact.respond_to?("custom_field_values")

        text
      end
    end

    module InstanceMethods
    end
  end
end
