module RedmineImproveCustomFields

  module Patches
    module IssuePatch
      def self.included(base) # :nodoc
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development

          alias_method_chain :available_custom_fields, :tracker_position

          before_validation :auto_subject
          after_validation :cast_custom_field_values

        end
      end

      module InstanceMethods
        def auto_subject
          self.subject = tracker.fetch_auto_subject(self) if tracker_id && !tracker.auto_subject.blank?
        end

        def available_custom_fields_with_tracker_position
          (project && tracker) ? (tracker.custom_fields.order('custom_fields_trackers.position ASC, custom_fields.position ASC') & project.all_issue_custom_fields) : []
        end

        def cast_custom_field_values
          self.custom_field_values = editable_custom_field_values.select {|cfv|
              cfv.custom_field.format.is_a?(Redmine::FieldFormat::Numeric)
            }.map { |cfv|
              { cfv.custom_field_id => cfv.custom_field.format.cast_value(cfv.custom_field, cfv.value, self) }
            }.reduce({}, &:merge)
        end

      end
    end
  end
end
