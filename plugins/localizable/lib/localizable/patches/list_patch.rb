module Localizable
  module Patches
    module ListPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          alias_method_chain :cast_single_value, :localizable
          alias_method_chain :select_edit_tag, :localizable
          alias_method_chain :check_box_edit_tag, :localizable
        end
      end

      module ClassMethods; end


      module InstanceMethods
        def cast_single_value_with_localizable(custom_field, value, customized=nil)
          localizable_value(value).to_s
        end

        def select_edit_tag_with_localizable(view, tag_id, tag_name, custom_value, options={})
          blank_option = ''.html_safe
          unless custom_value.custom_field.multiple?
            if custom_value.custom_field.is_required?
              unless custom_value.custom_field.default_value.present?
                blank_option = view.content_tag('option', "--- #{l(:actionview_instancetag_blank_option)} ---", :value => '')
              end
            else
              blank_option = view.content_tag('option', '&nbsp;'.html_safe, :value => '')
            end
          end

          options_tags = blank_option + view.options_for_select(possible_custom_values(custom_value), custom_value.value)
          s = view.select_tag(tag_name, options_tags, options.merge(:id => tag_id, :multiple => custom_value.custom_field.multiple?))
          if custom_value.custom_field.multiple?
            s << view.hidden_field_tag(tag_name, '')
          end
          s
        end

        # Renders the edit tag as check box or radio tags
        def check_box_edit_tag_with_localizable(view, tag_id, tag_name, custom_value, options={})
          opts = []
          unless custom_value.custom_field.multiple? || custom_value.custom_field.is_required?
            opts << ["(#{l(:label_none)})", '']
          end
          opts += possible_custom_value_options(custom_value)
          s = ''.html_safe
          tag_method = custom_value.custom_field.multiple? ? :check_box_tag : :radio_button_tag
          opts.each do |label, value|
            value ||= label
            checked = (custom_value.value.is_a?(Array) && custom_value.value.include?(value)) || custom_value.value.to_s == value
            tag = view.send(tag_method, tag_name, value, checked, :id => tag_id)
            # set the id on the first tag only
            tag_id = nil
            s << view.content_tag('label', tag + ' ' + localizable_value(label))
          end
          if custom_value.custom_field.multiple?
            s << view.hidden_field_tag(tag_name, '')
          end
          css = "#{options[:class]} check_box_group"
          view.content_tag('span', s, options.merge(:class => css))
        end
      end

      private

      def possible_custom_values(custom_value)
        if ['user', 'group', 'bool', 'enumeration'].include? custom_value.custom_field.field_format || (! custom_value.custom_field.is_possible_values_localizable?)
          possible_custom_value_options(custom_value)
        else
          possible_custom_value_options(custom_value).map {|value| [localizable_value(value), value]  }
        end
      end

      def localizable_value(value)
        (Setting.plugin_localizable["locales"] && Setting.plugin_localizable["locales"]["possible_values"] && Setting.plugin_localizable["locales"]["possible_values"][value] && !Setting.plugin_localizable["locales"]["possible_values"][value][User.current.language.to_s].blank? && Setting.plugin_localizable["locales"]["possible_values"][value][User.current.language.to_s]) || value
      end
    end
  end
end
