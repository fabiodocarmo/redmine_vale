module Portal
  module Patches
    module ProjectPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen

          safe_attributes 'key_words'
        end
      end

      module ClassMethods
      end

      module InstanceMethods
      end
    end
  end
end
