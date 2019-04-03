module GestorChamadas
  module JournalsHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do

        alias_method_chain :render_notes, :disabled_archived_edit

      end
    end

    module InstanceMethods
      def render_notes_with_disabled_archived_edit(issue, journal, options={})
        if issue.editable?
          render_notes_without_disabled_archived_edit(issue, journal, options={})
        else
          content = ''
          links = []
          content << content_tag('div', links.join(' ').html_safe, :class => 'contextual') unless links.empty?
          content << textilizable(journal, :notes)
          css_classes = "wiki"
          content_tag('div', content.html_safe, :id => "journal-#{journal.id}-notes", :class => css_classes)
        end

      end
    end
  end
end
