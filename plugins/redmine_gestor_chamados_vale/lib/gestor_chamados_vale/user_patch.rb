# encoding: UTF-8
module GestorChamadosVale
  module UserPatch
    def self.included(base) # :nodoc
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        def self.valid_notification_options(user=nil)
          # Note that @user.membership.size would fail since AR ignores
          # :include association option when doing a count
          if user.nil?
            User::MAIL_NOTIFICATION_OPTIONS.reject{|option| option.first == 'selected' || option.first == 'only_assigned' || option.first == 'only_owner' || option.first == 'none' }
          elsif user.admin?
            User::MAIL_NOTIFICATION_OPTIONS
          else
            User::MAIL_NOTIFICATION_OPTIONS.reject{|option| option.first == 'selected' || option.first == 'only_assigned' || option.first == 'only_owner' || option.first == 'none' }
          end
        end
      end
    end

    module ClassMethods;  end

    module InstanceMethods;  end
  end
end
