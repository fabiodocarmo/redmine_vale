module RedmineApiIntegrations
  module Patches
    # Patches Redmine's Issues Controller dynamically.  Adds a +after_save+ filter.
    module CustomFieldsControllerPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          before_filter :show_cf, only: [:index], if: :api_request?
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def show_cf
          if params[:cf_id].present?
            begin
              @custom_field = CustomField.find(params[:cf_id].to_i)
            rescue ActiveRecord::RecordNotFound => e
              @custom_field = nil
            end
          end

          respond_to do |format|
            format.api { render :action => 'id_error', :status => :unprocessable_entity } if !params[:cf_id].present?
            format.api { render :action => 'id_not_found', :status => 404 } if @custom_field.nil?
            format.api { render :action => 'show' } 
          end
        end
      end
    end
  end
end
