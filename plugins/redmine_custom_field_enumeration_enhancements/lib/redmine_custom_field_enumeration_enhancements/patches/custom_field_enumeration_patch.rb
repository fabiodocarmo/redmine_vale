module RedmineCustomFieldEnumerationEnhancements
  module Patches
    module CustomFieldEnumerationPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen

          attr_accessible :key
        end
      end

      module ClassMethods
      end

      module InstanceMethods
      end
    end
  end
end
