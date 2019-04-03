module RedmineImproveImportIssues
  # Patches Redmine's Issues Controller dynamically.  Adds a +after_save+ filter.
  module Patches
    module ImportPatch

      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          # alias_method_chain :read_rows, :other_types
          alias_method_chain :run, :other_types

        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def run_with_other_types(options={})
          if self.settings["file_type"] == "xlsx"
            ImportXlsxIssueJob.perform_later(self, User.current)
            update_attribute :finished, true
            update_attribute :total_items, 10
            current = 10
          else
            max_items = options[:max_items]
            max_time = options[:max_time]
            current = 0
            imported = 0
            resume_after = items.maximum(:position) || 0
            interrupted = false
            started_on = Time.now

            read_items do |row, position|
              if (max_items && imported >= max_items) || (max_time && Time.now >= started_on + max_time)
                interrupted = true
                break
              end
              if position > resume_after
                item = items.build
                item.position = position

                if object = build_object(row)
                  if object.save
                    item.obj_id = object.id
                  else
                    item.message = object.errors.full_messages.join("\n")
                  end
                end

                item.save!
                imported += 1
              end
              current = position
            end

            if imported == 0 || interrupted == false
              if total_items.nil?
                update_attribute :total_items, current
              end
              update_attribute :finished, true
              remove_file
            end

            current
          end
        end
      end
    end
  end
end
