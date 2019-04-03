module RedmineImproveCustomFields

  module Patches
    module FieldFormatBasePatch
      def self.included(base) # :nodoc
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
        end
      end

      module InstanceMethods

        def convert_value(custom_field, value)
          value
        end

      end

    end
  end
end


Redmine::FieldFormat::Base.send(:include, RedmineImproveCustomFields::Patches::FieldFormatBasePatch) unless Redmine::FieldFormat::Base.included_modules.include? RedmineImproveCustomFields::Patches::FieldFormatBasePatch
