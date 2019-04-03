module RedmineImproveCustomFields

  module Patches
    module CustomFieldPatch
      def self.included(base) # :nodoc
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development

          has_many :autocomplete_options, class_name: 'Improvecf::AutocompleteOption', dependent: :destroy
          before_save :write_autocomplete_options, if: "edit_tag_style == 'autocomplete'"
        end
      end

      module InstanceMethods
        def write_autocomplete_options
          aux_autocomplete_options = []
          self.possible_values.each do |value|
            autocomplete_option = Improvecf::AutocompleteOption.new
            autocomplete_option.custom_field_id = self.id
            autocomplete_option.value = value
            aux_autocomplete_options << autocomplete_option
          end
          self.class.transaction do
            self.autocomplete_options.delete_all # performance reason
            self.autocomplete_options = aux_autocomplete_options
          end
        end
      end

    end
  end
end
