module RedmineAutoGenerateIssue
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen

          # It must to be around to run before send_notification
          around_update :create_issues_by_status_trigger
          around_create :create_issues_by_status_trigger
          after_save :save_attachment_relationships

          alias_method_chain :send_notification, :generate_issue

          attr_accessor :do_not_send_notification
          attr_accessor :notify_creation_of
        end

        if RUBY_VERSION <= '1.9.3'
          base.before_add_for_attachments << lambda do |issue, attachment|
            issue.try_create_issues_with_attachments(attachment)
          end
        else
          base.before_add_for_attachments << lambda do |_, issue, attachment|
            issue.try_create_issues_with_attachments(attachment)
          end
        end
      end

      module ClassMethods; end

      module InstanceMethods
        # Callback on file attachment
        def try_create_issues_with_attachments(attachment)
          Issue.transaction do
            @attachment_relationships ||= []
            @attachment_relationships = @attachment_relationships | AutoIssueAttachmentTrigger.where({
              status_id: status_id,
              project_id: project_id,
              tracker_id: tracker_id
            }).map {|t| t.create_issues(self, attachment) }.flatten if attachment.content_type.in? AttachmentAutoIssue::VALID_FORMATS
          end
        end

        def save_attachment_relationships
          return if @attachment_relationships.blank?

          @attachment_relationships.each do |new_issue|
            create_relation(new_issue)
          end.group_by(&:assigned_to_id).select { |k,_| k }.each do |assigned_to_id, issues|
            AutoIssueMailer.notify_attachment_relationship(id, assigned_to_id, issues.map(&:id)).deliver
          end
        end

        def create_issues_by_status_trigger
          yield

          self.notify_creation_of = []
          AutoIssueStatusTrigger.where(trigger_params).each do |t|
            new_issue = t.build_issue(self)
            new_issue.do_not_send_notification = !t.send_email
            new_issue.save!(:validate => false)
            self.notify_creation_of << new_issue if t.notify_on_previous_email
            create_relation(new_issue)
          end
        end

        private

        def create_relation(new_issue)
          relation = IssueRelation.new(relation_type: IssueRelation::TYPE_RELATES)
          relation.issue_to   = new_issue
          relation.issue_from = self
          relation.save!
        end

        def send_notification_with_generate_issue
          return if do_not_send_notification
          send_notification_without_generate_issue
        end

        def trigger_params
          {
            status_to_id: status_id,
            status_from_id: status_id_was,
            project_id: project_id,
            tracker_id: tracker_id
          }
        end
      end
    end
  end
end
