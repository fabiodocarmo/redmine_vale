# encoding: UTF-8

module DependentFieldsManagement
  module ListFormatPatch

    def self.included(base) # :nodoc
      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do

        alias_method_chain :possible_custom_value_options, :dependent

      end
    end

    module InstanceMethods

      def possible_custom_value_options_with_dependent(custom_value)
        if custom_value.custom_field.is_a? IssueCustomField
          dependent_fields = DependentField.where(avaliable: true)
                                            .where(project_id: custom_value.customized.project_id)
                                            .where(tracker_id: custom_value.customized.tracker_id)
                                            .where(secondary_field_id: custom_value.custom_field_id)
                                            .where(dependent_type: 'value')
                                            .where("secondary_field_value is not null and secondary_field_value != ''")
                                            .where(DependentField.main_custom_value_condition(custom_value.customized.custom_field_values))
                                            .all

          possible_values = dependent_fields.select { |df| !df.secondary_field_value.blank? }.map do |dependency_rule|
            dependency_rule.secondary_field_value.split(';').map { |value| value.strip  }
          end

          possible_values.reduce(possible_custom_value_options_without_dependent(custom_value), &:&)
        else
          possible_custom_value_options_without_dependent(custom_value)
        end
      end

    end
  end
end
