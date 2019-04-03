# encoding: UTF-8
module Patches
  module GridIssuePatch

    def self.included(base) # :nodoc:
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        base.send(:include, InstanceMethods)
        validate :grid_validation

        alias_method_chain :validate_required_fields, :grid
      end
    end

    module InstanceMethods

      def validate_required_fields_with_grid
        user = new_record? ? author : current_journal.try(:user)

        required_attribute_names(user).each do |attribute|
          if attribute =~ /^\d+$/
            attribute = attribute.to_i
            v = custom_field_values.detect {|v| v.custom_field_id == attribute }

            if v && (Array(v.value).detect(&:present?).nil? || v.value_blank?)
              errors.add :base, v.custom_field.name + ' ' + l('activerecord.errors.messages.blank')
            end
          else
            if respond_to?(attribute) && send(attribute).blank? && !disabled_core_fields.include?(attribute)
              next if attribute == 'category_id' && project.try(:issue_categories).blank?
              next if attribute == 'fixed_version_id' && assignable_versions.blank?

              errors.add attribute, :blank
            end
          end
        end
      end

      def grid_custom_field_values
        self.visible_custom_field_values(User.current)
            .select { |cfv| cfv.custom_field.field_format == Patches::FieldFormatPatch::GridFormat.name_id }
      end

      def grid_validation
        validated_fields = true
        validated_grid = true
        custom_field_values.each do |custom_field_value|
          if(custom_field_value.custom_field.field_format == "grid")
            validate_grid_columns(custom_field_value)

            all_blank = true
            unless custom_field_value.value.blank?
              grid_columns = custom_field_value.custom_field.sorted_grid_columns
              grid_lines = JSON.parse custom_field_value.value.gsub('=>',':')
              if (Setting.plugin_grid_custom_field[:max_number_rows] != "" && grid_lines.count > Setting.plugin_grid_custom_field[:max_number_rows].to_i)
                errors.add(:base, "#{custom_field_value.custom_field.name}  #{I18n.t('grid_custom_field.max_num_rows', count: Setting.plugin_grid_custom_field[:max_number_rows])}")
              end
              sequential_line_number = 0;
              grid_lines.each do |rowindex, row|
                sequential_line_number = sequential_line_number +1;
                grid_columns.each do |column|
                  value = row[column.id.to_s]
                  cfv = CustomFieldValue.new(customized:self, custom_field: column, value_was: '', value:value);
                  val_errors = column.validate_custom_value(cfv)
                  if(!val_errors.empty?)
                    val_errors.each do |erro|
                      errors.add(cfv.custom_field.name, I18n.t('grid_custom_field.column_validation_error_message',
                                    error_msg: erro, field: custom_field_value.custom_field.name) + ' - ' + I18n.t('grid_custom_field.row') + ' ' + (sequential_line_number).to_s)
                      validated_fields = false
                    end
                  end
                  if(!value.blank?)
                    all_blank = false
                  end
                end
              end
            end
          end
          if(custom_field_value.custom_field.is_required && all_blank)
            errors.add(custom_field_value.custom_field.name, I18n.t('activerecord.errors.messages.blank'))
            validated_grid = false
          end
        end
        return validated_fields || validated_grid
      end
    end

    def validate_grid_columns(custom_field_value)
      return [] if custom_field_value.value.nil?
      grid_custom_field = custom_field_value.custom_field
      valid_column_ids = grid_custom_field.sorted_grid_columns.map(&:id).map(&:to_s)

      grid_hash_value = custom_field_value.value.to_s.gsub('=>', ':')
      if grid_hash_value.present?
        hash = JSON.parse(grid_hash_value)
        hash.each do |row, columns|
          invalid_columns = (columns.keys - valid_column_ids)
          if ! invalid_columns.blank?
            errors.add(:base, "#{grid_custom_field.name}  #{I18n.t('grid_custom_field.invalid_columns_error_message')}")
          end
        end
      end
    end

  end
end
