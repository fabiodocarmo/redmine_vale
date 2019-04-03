module Portal
  module Patches
    module ApplicationHelperPatch
      def self.included(base) # :nodoc
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen

          alias_method_chain :link_to_project, :new_issue
        end
      end

      module InstanceMethods
        def link_to_project_with_new_issue(project, options={}, html_options=nil)
          if Setting.plugin_portal[:default_project_page] == "new_issue" && User.current.allowed_to?(:add_issues, project) && project.trackers.any?
            s = link_to project.name, new_project_issue_url(project, {:only_path => true}.merge(options)), html_options
          else
            s = link_to_project_without_new_issue(project, options, html_options)
          end
        end
      end
    end
  end
end
