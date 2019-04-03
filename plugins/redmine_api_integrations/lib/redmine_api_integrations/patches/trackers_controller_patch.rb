module RedmineApiIntegrations
  module Patches
    # Patches Redmine's Issues Controller dynamically.  Adds a +after_save+ filter.
    module TrackersControllerPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          before_filter :show_trackers, only: [:index], if: :api_request?
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def show_trackers
          begin
            @trackers = ApiIntegration.get_trackers_api_integration
          rescue ActiveRecord::RecordNotFound => e
            @trackers = []
          end

          respond_to do |format|
            format.api { render :action => 'show' } 
          end
        end
      end
    end
  end
end
