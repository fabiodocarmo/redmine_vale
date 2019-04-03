module GestorChamadas
  # Patches Redmine's Issues Controller dynamically.  Adds a +after_save+ filter.
  module AttachmentsControllerPatch
    def self.included(base) # :nodoc
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in developmen
        def check_if_login_required
          false
        end
      end
    end

    module ClassMethods

    end

    module InstanceMethods
    end
  end
end
