module AutoAssign
  module Patches
    # Patches Redmine's Issues Controller dynamically.  Adds a +after_save+ filter.
    module IssuesControllerPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          before_filter :verify_auto_assign_by_open, only: :show
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def verify_auto_assign_by_open
          return if action_name != 'show'
          return if !@issue || !@issue.assigned_to.kind_of?(Group) || !@issue.assigned_to.users.include?(User.current)

          if AtribuicaoAutomatica.find_open_redistribute_by_issue(@issue).first
            @issue.init_journal(User.current)
            @issue.assigned_to = User.current
            @issue.save(validate: false)

            @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
          end
        end
      end
    end
  end
end
