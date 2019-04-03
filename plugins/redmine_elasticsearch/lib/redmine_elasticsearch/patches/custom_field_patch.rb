module RedmineElasticsearch
  module Patches
    module CustomFieldPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen

          after_save     :async_update_index

          before_destroy :cache_trackers_ids, if: 'searchable?'
          after_destroy  :async_destroy_index, if: 'searchable?'
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def cache_trackers_ids
          @trackers = trackers.pluck(:id) if self.class.customized_class == Issue && self.searchable?
        end

        def async_destroy_index
          scope = self.class.customized_class

          if scope.included_modules.include?(::ApplicationSearch)
            scope = scope.where(tracker_id: @trackers) if @trackers
            scope.select(:id).find_each(batch_size: 5000).each(&:async_update_index)
          end
        end

        def async_update_index
          scope = self.class.customized_class

          if scope.included_modules.include?(::ApplicationSearch) && searchable_changed?
            if scope == Issue
              scope = scope.joins(:custom_values)
                           .where(custom_values: {custom_field_id: id})
                           .where("value != '' and value is not null")
            end

            scope.select(:id).find_each(batch_size: 5000).each(&:async_update_index)
          end
        end
      end
    end
  end
end
