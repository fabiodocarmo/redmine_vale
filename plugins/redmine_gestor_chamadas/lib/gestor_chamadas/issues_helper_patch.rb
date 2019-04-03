module GestorChamadas
  module IssuesHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do

        alias_method_chain :authorize_for, :disabled_archived_edit

      end
    end

    module InstanceMethods

      def authorize_for_with_disabled_archived_edit(controller, action)
        authorized = authorize_for_without_disabled_archived_edit(controller, action)
        if params[:controller] == 'issues' && ['show', 'edit'].include?(params[:action])
          authorized = authorized && @issue.editable?
        elsif params[:controller] == 'journals' && ['show', 'edit'].include?(params[:action])
          authorized = authorized && @journal.journalized.editable?
        end
        authorized
      end

    end
  end
end
