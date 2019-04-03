module Localizable
  module Patches
    module MailerPatch

      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          alias_method_chain :issue_add, :localizable
          alias_method_chain :issue_edit, :localizable

          def self.deliver_issue_add(issue)
            to = issue.notified_users
            cc = issue.notified_watchers - to

            previous_language = current_language

            all_notified_users = to + cc
            all_notified_users.group_by(&:language).each do |language, addressees|

              set_language_if_valid language

              issue.each_notification(addressees) do |users|
                Mailer.issue_add(issue, to & users, cc & users, language).deliver
              end
            end
          end

          def self.deliver_issue_edit(journal)
            issue = journal.journalized.reload
            to = journal.notified_users
            cc = journal.notified_watchers - to

            previous_language = current_language

            all_notified_users = to + cc
            all_notified_users.group_by(&:language).each do |language, addressees|

              set_language_if_valid language

              journal.each_notification(addressees) do |users|
                issue.each_notification(users) do |users2|
                  Mailer.issue_edit(journal, to & users2, cc & users2, language).deliver
                end
              end
            end

            set_language_if_valid previous_language

          end

        end
      end

      module InstanceMethods

        def issue_add_with_localizable(issue, to_users, cc_users, language = nil)
          set_language_if_valid language if language
          issue_add_without_localizable(issue, to_users, cc_users)
        end

        def issue_edit_with_localizable(journal, to_users, cc_users, language = nil)
          set_language_if_valid language if language
          issue_edit_without_localizable(journal, to_users, cc_users)
        end

      end

    end
  end
end

Mailer.send(:include, Localizable::Patches::MailerPatch) unless Mailer.included_modules.include?(Localizable::Patches::MailerPatch)
