module LabelCustomFieldPatches
  module CustomValuePatch

    def self.included(base) # :nodoc:
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        before_save :clear_value, if: 'custom_field.format.is_a? LabelFormat'
      end
    end

    def clear_value
        self.value = ''
    end

  end
end
