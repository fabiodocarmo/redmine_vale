# encoding: UTF-8

module GestorChamadas
  module UserPatch
    def self.included(base) # :nodoc
      base.send(:include, InstanceMethods)
      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        alias_method_chain :roles_for_project, :dependent
      end
    end

    module InstanceMethods
      # Return user's roles for project
      def roles_for_project_with_dependent(project)
        
        # No role on archived projects
        return [] if project.nil? || project.archived?
        if membership = membership(project)
          membership.roles.dup
        elsif project.is_public? || Setting.plugin_redmine_gestor_chamadas[:projects].include?(project.id.to_s)
          project.override_roles(builtin_role)
        else
          []
        end
      end
    end
  end
end
