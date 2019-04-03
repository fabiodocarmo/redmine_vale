module RedmineApiIntegrations
  module Patches
    module UsersControllerPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          before_filter :show_user, only: [:show, :index], if: :api_request?
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def show_user

          if params[:mail].present?
            email = EmailAddress.where(:address => params[:mail]).first
            if email.nil?
              @user = email
            else
              @user = User.find(email.user_id)
            end
          end

          respond_to do |format|
            format.api { render :action => 'mail_error', :status => :unprocessable_entity } if !params[:mail].present?
            format.api { render :action => 'show_nil' } if @user.nil?
            format.api { render :action => 'show' } 
          end
        end
      end
    end
  end
end
