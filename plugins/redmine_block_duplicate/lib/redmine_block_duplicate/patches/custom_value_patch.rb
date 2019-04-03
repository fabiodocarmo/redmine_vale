module RedmineBlockDuplicate
  module Patches
    module CustomValuePatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          before_save :set_value_hashed
        end
      end

      module InstanceMethods
        def set_value_hashed
          if (value)
            self.value_hashed = Digest::SHA256.hexdigest(self.value)
          end
        end
      end

    end
  end
end
