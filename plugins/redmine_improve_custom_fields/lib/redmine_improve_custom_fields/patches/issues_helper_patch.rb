module RedmineImproveCustomFields
  # Patches Redmine's Issues Controller dynamically.  Adds a +after_save+ filter.
  module Patches
    module IssuesHelperPatch
      def self.included(base) # :nodoc
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          alias_method_chain :render_custom_fields_rows, :improve_fields

          def render_custom_fields_for_redmine_3_2(values)
            s = "<div class=\"splitcontent improve_fields_issue_show\">\n"
            content_left_count = 0

            values.compact.each do |value|
              css = "cf_#{value.custom_field.id}"

              if content_left_count == 2
                s << "</div>\n" #splitcontent
                s << "<div class=\"splitcontent improve_fields_issue_show\">"
                content_left_count = 0
              end

              if value.custom_field.big_size
                s << "</div>\n" #splitcontent
                s << "<div class=\"splitcontent improve_fields_issue_show\">"

                if value.custom_field.hide_label
                  s << "<div class=\"#{css} value\">#{ h(show_value(value)) }</div>\n"
                else
                  s << "<div class=\"#{css} attribute\">\n"
                  s << "<div class=\"#{css} label\">#{ custom_field_name_tag(value.custom_field) }:</div><div class=\"#{css} #{value.custom_field.field_format} value\">#{ h(show_value(value)) }</div>\n"
                  s << "</div>\n" #attribute
                end

                content_left_count = 2

              else
                s << "<div class=\"splitcontentleft\">\n"
                content_left_count = content_left_count + 1

                if value.custom_field.hide_label
                  s << "<div class=\"#{css} value\">#{ h(show_value(value)) }</div>\n"
                else
                  s << "<div class=\"#{css} attribute\">\n"
                  s << "<div class=\"#{css} label\">#{ custom_field_name_tag(value.custom_field) }:</div><div class=\"#{css} #{value.custom_field.field_format} value\">#{ h(show_value(value)) }</div>\n"
                  s << "</div>\n" #attribute

                end

                s << "</div>\n" #splitcontentleft

              end
            end
            s << "</div>\n"
            s.html_safe
          end

          def render_custom_fields_for_older_redmine(values)
            s = "<tr>\n"
            close_tr = false

            values.compact.each do |value|
              css = "cf_#{value.custom_field.id}"

              if value.custom_field.big_size
                s << "</tr>\n" if close_tr
                s << "<tr>\n"

                if value.custom_field.hide_label
                  s << "<td colspan='4' class=\"#{css}\">#{ h(show_value(value)) }</td>\n"
                else
                  if Redmine::VERSION::MAJOR >= 3
                    s << "\t<th class=\"#{css}\">#{ custom_field_name_tag(value.custom_field) }:</th><td colspan='3' class=\"#{css}\">#{ h(show_value(value)) }</td>\n"
                  else
                    s << "\t<th class=\"#{css}\">#{ h(value.custom_field.name) }:</th><td colspan='3' class=\"#{css}\">#{ h(show_value(value)) }</td>\n"
                  end
                end

                close_tr = true
              else
                s << "</tr>\n<tr>\n" if close_tr

                if value.custom_field.hide_label
                  s << "\t<td colspan='2' class=\"#{css}\">#{ h(show_value(value)) }</td>\n"
                else
                  if Redmine::VERSION::MAJOR >= 3
                    s << "\t<th class=\"#{css}\">#{ custom_field_name_tag(value.custom_field) }:</th><td class=\"#{css}\">#{ h(show_value(value)) }</td>\n"
                  else
                    s << "\t<th class=\"#{css}\">#{ h(value.custom_field.name) }:</th><td class=\"#{css}\">#{ h(show_value(value)) }</td>\n"
                  end
                end
                close_tr = !close_tr
              end
            end
            s << "</tr>\n"
            s.html_safe
          end
        end
      end

      module InstanceMethods

        def render_custom_fields_rows_with_improve_fields(issue)
          values = issue.visible_custom_field_values
          return if values.empty?

          if Redmine::VERSION::MAJOR >= 3 && Redmine::VERSION::MINOR >= 2
            render_custom_fields_for_redmine_3_2 values
          else
            render_custom_fields_for_older_redmine values
          end
        end
      end
    end
  end
end
