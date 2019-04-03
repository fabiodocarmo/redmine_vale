module Patches
  module FieldFormatBasePatch
    def self.included(base) # :nodoc:
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        base.send(:include, InstanceMethods)
      end
    end

    module InstanceMethods
      def value_blank?(value)
        value.blank?
      end
    end
  end
end
