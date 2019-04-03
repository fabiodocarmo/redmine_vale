module RedmineImproveCustomFields
  # Patches Redmine's Issues Controller dynamically.  Adds a +after_save+ filter.
  module Patches
    module TrackersControllerPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          before_filter :set_custom_fields_position, :only => [:update, :create]
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def set_custom_fields_position
          return unless tracker = Tracker.where(id: params[:id]).first

          saved_custom_fields = tracker.custom_fields_trackers
          custom_fields_to_update = []
          ordered_custom_fields = []
          custom_fields = params[:tracker].delete(:custom_field_ids)

          return nil if custom_fields.blank?

          custom_fields.each_with_index do |custom_field, i|
            next if custom_field.blank?
            hash = {custom_field_id:custom_field, position:i}
            saved_custom_field = saved_custom_fields.detect {|k| k.custom_field_id == custom_field.to_i}

            if saved_custom_field && saved_custom_field.id
              hash[:id] = saved_custom_field.id
              custom_fields_to_update << saved_custom_field
            end

            ordered_custom_fields << hash
          end

          custom_fields_to_delete = saved_custom_fields - custom_fields_to_update

          if !custom_fields_to_delete.blank?
            custom_fields_to_delete.each do |g|
              hash = {id:g.id, _destroy: '1'}
              ordered_custom_fields << hash
            end
          end

          params[:tracker][:custom_fields_trackers_attributes] = ordered_custom_fields
        end
      end
    end
  end
end
