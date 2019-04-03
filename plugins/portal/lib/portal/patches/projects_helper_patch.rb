module Portal
  module Patches
    module ProjectsHelperPatch
      def self.included(base) # :nodoc
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen

          alias_method_chain :render_project_hierarchy, :key_words
        end
      end

      module InstanceMethods
        def render_project_hierarchy_with_key_words(projects)
          render_project_nested_lists(projects) do |project|
            s = link_to_project(project, {}, :class => "#{project.css_classes} #{User.current.member_of?(project) ? 'my-project' : nil}")

            if Setting.plugin_portal[:show_tracker_at_home] && User.current.allowed_to?(:add_issues, project)
              trackers = ''

              Issue.allowed_target_trackers(project).each do |tracker|
                trackers << link_to(tracker, project_issues_new_path(project, 'issue[tracker_id]' => tracker.id), class: 'tracker')
              end

              s <<  content_tag('div', trackers.html_safe, class: 'trackers')
            end

            if project.key_words.present?
              s << content_tag('div', project.key_words, class: 'key_words', style: 'display:none;')
            end

            s
          end
        end
      end
    end
  end
end
