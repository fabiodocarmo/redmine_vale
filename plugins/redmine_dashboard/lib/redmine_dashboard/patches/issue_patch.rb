module RedmineDashboard
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen

          scope :filtered_issues, lambda { |filters, projects, exclude_statuses|
            filtered = joins([:project, :status, :priority, :tracker])

            filters.each do |k, v|
              begin
                if match = k.match(/custom_field_(\d+)/)
                  filtered = send("filter_custom_field", filtered, match[1], v)
                else
                  filtered = send("filter_#{k}", filtered, v)
                end
              rescue
                filtered = send("where_filter", filtered, k, v)
              end
            end

            filtered.where(project_id: projects).where('(? is NULL or status_id not in (?))', exclude_statuses, exclude_statuses)
          }

          scope :group_by_with_time_segmentation, lambda { |time_segmentation, column|
            case connection.adapter_name
            when "PostgreSQL"
              group("DATE(date_trunc('#{time_segmentation}', #{column}))")
            else
              raise "Unsupported Database"
            end.count
          }
        end
      end

      module ClassMethods
        def filter_range_date_from(filtered, v)
          filtered
        end

        def filter_range_date_to(filtered, v)
          filtered
        end

        def filter_time_segmentation(filtered, v)
          filtered
        end

        def filter_custom_field(filtered, cf_id, v)
          unless v.blank?
            filtered = filtered.joins("inner join custom_values cf_#{cf_id} on cf_#{cf_id}.customized_id = issues.id")
                               .where("cf_#{cf_id}" => { value: v, custom_field_id: cf_id })
          end

          filtered
        end

        def where_filter(filtered, key, value)
          value.blank? ? filtered : filtered.where(key => value)
        end
      end

      module InstanceMethods
      end
    end
  end
end
