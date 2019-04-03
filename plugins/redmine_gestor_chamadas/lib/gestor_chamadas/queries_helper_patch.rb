module GestorChamadas
  module QueriesHelperPatch
    def self.included(receiver)
      receiver.send :include, InstanceMethods

      receiver.class_eval do
        unloadable

        alias_method :column_value, :column_value_with_project
        alias_method :csv_value, :csv_value_with_project
      end
    end

    module InstanceMethods

      def csv_value_with_project(column, object, value)
        format_object(value, false) do |value|
          case value.class.name
          when 'Float'
            sprintf("%.2f", value).gsub('.', l(:general_csv_decimal_separator))
          when 'IssueRelation'
            splittedValue = value.to_s.split( )
            splittedValue[0] + " " + splittedValue[1] +  " #{value.other_issue(object).project.name} #{value.other_issue(object).id}"
          when 'Issue'
            if object.is_a?(TimeEntry)
              "#{value.tracker} ##{value.id}: #{value.subject}"
            else
              value.id
            end
          else
            value
          end
        end
      end

      def column_value_with_project(column, issue, value)
        case column.name
        when :id
          link_to value, issue_path(issue)
        when :subject
          link_to value, issue_path(issue)
        when :parent
          value ? (value.visible? ? link_to_issue(value, :subject => false) : "#{value.tracker} ##{value.id}: #{value.subject}") : ''
        when :description
          issue.description? ? content_tag('div', textilizable(issue, :description), :class => "wiki") : ''
        when :done_ratio
          progress_bar(value, :width => '80px')
        when :relations
          content_tag('span',
            value.to_s(issue) {|other| "#{other.project.name} " + link_to_issue(other, :subject => false, :tracker => false)}.html_safe,
            :class => value.css_classes_for(issue))
        else
          format_object(value)
        end
      end
    end
  end
end
