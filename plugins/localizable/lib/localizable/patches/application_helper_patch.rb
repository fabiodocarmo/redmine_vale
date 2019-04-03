module Localizable
  module Patches
    module ApplicationHelperPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          alias_method_chain :textilizable, :localizable

          def translate(original_value, type)
            if Setting["plugin_localizable"]
              if Setting["plugin_localizable"]["locales"]
                if Setting["plugin_localizable"]["locales"][type]
                  if Setting["plugin_localizable"]["locales"][type][original_value]
                    unless Setting["plugin_localizable"]["locales"][type][original_value][User.current.language.to_s].blank?
                      value = Setting["plugin_localizable"]["locales"][type][original_value][User.current.language.to_s]
                    end
                  end
                end
              end
            end
            return(value)
          end

          def translate_value(value, type)
            if !translate(value, type).nil?
              value = translate(value, type)
            else
              value
            end
          end

        end
      end

      module ClassMethods
      end

      module InstanceMethods
        # Return a string used to display a custom value
        def textilizable_with_localizable(*args)
          options = args.last.is_a?(Hash) ? args.pop : {}
          case args.size
          when 1
            obj = options[:object]
            text = args.shift
          when 2
            obj = args.shift
            attr = args.shift
            text = obj.send(attr).to_s

            text = translate_value(text, :tracker_descriptions)
          else
            raise ArgumentError, 'invalid arguments to textilizable'
          end
          return '' if text.blank?
          project = options[:project] || @project || (obj && obj.respond_to?(:project) ? obj.project : nil)
          @only_path = only_path = options.delete(:only_path) == false ? false : true

          text = text.dup
          macros = catch_macros(text)
          text = Redmine::WikiFormatting.to_html(Setting.text_formatting, text, :object => obj, :attribute => attr)

          @parsed_headings = []
          @heading_anchors = {}
          @current_section = 0 if options[:edit_section_links]

          parse_sections(text, project, obj, attr, only_path, options)
          text = parse_non_pre_blocks(text, obj, macros) do |text|
            [:parse_inline_attachments, :parse_wiki_links, :parse_redmine_links].each do |method_name|
              send method_name, text, project, obj, attr, only_path, options
            end
          end
          parse_headings(text, project, obj, attr, only_path, options)

          if @parsed_headings.any?
            replace_toc(text, @parsed_headings)
          end

          text.html_safe
        end
      end
    end
  end
end
