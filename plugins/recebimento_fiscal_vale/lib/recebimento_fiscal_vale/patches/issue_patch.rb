module RecebimentoFiscalVale
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen

          after_commit :exec_doc_type
        end
      end

      module ClassMethods; end

      module InstanceMethods

        def exec_doc_type
          user = Setting.plugin_recebimento_fiscal_vale['user'].to_i
          user = User.current.id if user == 0
          DocumentTypeQuery.find_by_issue(self).each do |ev|
            AsyncDocumentTypeQuery.perform_later(user, id, ev.id, 0)
          end
        end
      end
    end
  end
end
