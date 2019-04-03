module RedmineImproveCustomFields
  module Patches
    module TrackerPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          has_many :improvecf_group_priorities, class_name: 'Improvecf::GroupPriority'
          accepts_nested_attributes_for :improvecf_group_priorities, reject_if: :all_blank, allow_destroy: true

          has_many :custom_fields_trackers, source: 'tracker'
          accepts_nested_attributes_for :custom_fields_trackers, :allow_destroy => true
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def fetch_auto_subject(issue)
          self.auto_subject.gsub(/\#\{(\w+)\}/) do
            expression = $1

            begin
              expression.match(/custom_field_(\d+)/) { issue.custom_field_value($1) } || issue.send(expression) || expression
            rescue
              expression
            end
          end
        end
      end
    end
  end
end
