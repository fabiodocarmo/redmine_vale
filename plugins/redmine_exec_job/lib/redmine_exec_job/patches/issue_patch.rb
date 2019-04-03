module RedmineExecJob
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen

          before_validation :exec_job_before_validation
          before_save       :exec_job_before_save
          after_commit      :exec_job_after_commit
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def exec_job_before_validation
          exec_job(:before_validation)
        end

        def exec_job_before_save
          exec_job(:before_save)
        end

        def exec_job_after_commit
          exec_job(:after_commit)
        end

        def exec_job(callback)
          ExecJob.find_by_issue_and_callback(self, callback).order(:id).each do |ej|
            if ej.run_sync
              ej.perform(self)
            else
              AsyncExecJob.perform_later(id, ej.id)
            end
          end
        end
      end
    end
  end
end
