module Patches
  module IssuesHelperPatch

    def self.included(base) # :nodoc
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        alias_method_chain :show_detail, :grid
        alias_method_chain :email_issue_attributes, :grid
      end
    end

    module InstanceMethods
      def show_detail_with_grid(detail, no_html=false, options={})
        if detail.property == 'cf' && detail.custom_field.try(:field_format) == Patches::FieldFormatPatch::GridFormat.name_id
          no_html = true
        end
        show_detail_without_grid(detail, no_html, options)
      end

      def email_issue_attributes_with_grid(issue, user)
        items = []
        %w(author status priority assigned_to category fixed_version).each do |attribute|
          unless issue.disabled_core_fields.include?(attribute+"_id")
            items << "#{l("field_#{attribute}")}: #{issue.send attribute}"
          end
        end

        issue.visible_custom_field_values(user).reject { |v| v.value.blank? }.each do |value|
          if (value.custom_field.field_format == "grid")
            grid_text = show_value(value, true).gsub("none","block")
            grid_text = grid_text.gsub("name=\"button\"", "style=\"display:none\"")
            grid_text = grid_text.gsub("<table","<table border=\"1\" style=\"border-collapse: collapse;text-align: center;\"")

            items << "#{value.custom_field.name}: #{grid_text}"
          else
            items << "#{value.custom_field.name}: #{show_value(value, false)}"
          end
        end

        items
      end
    end
  end
end
