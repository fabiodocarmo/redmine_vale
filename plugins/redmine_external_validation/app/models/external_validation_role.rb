class ExternalValidationRole < ActiveRecord::Base
  unloadable

  belongs_to :external_validation
  belongs_to :custom_field
  belongs_to :message_custom_field, class_name: 'IssueCustomField'

  belongs_to :error_status, class_name: 'IssueStatus'

  scope :ordered, -> { order(:position, :id) }

  FORMATS = [
    :integer,
    :float,
    :date,
    :current_month
  ]

  def compare_with_format(custom_value, query_validation, field_name, column_grid_id)
    if (cf = custom_value.custom_field) && (cf.field_format == "grid")
      keys = query_validation.keys.first
      row = grid_row_to_validate(custom_value, keys)

      compare_values(row[column_grid_id.to_s], query_validation.values.first[field_name])
    else
      compare_values(custom_value.value, query_validation.values.first[field_name])
    end
  end

  def compare_with_constant(validation_value)
    compare_values(constant_value, validation_value)
  end

  def compare_with_custom_field(custom_value, secondary_custom_value)
    compare_values(custom_value.value, secondary_custom_value.value)
  end

  private

  def grid_row_to_validate(custom_value, keys)
    JSON.parse(custom_value.value.gsub("=>", ":")).values.select do |row|
      grid_keys = keys.map(&:to_s) & row.keys
      grid_keys.map { |key| row[key].to_s == keys[key].to_s }.all?
    end.first
  end

  def compare_values(val1, val2)
    if self.format == "integer"
      val1.to_i == val2.to_i
    elsif self.format == "float"
      val1.to_f.in?  (val2.to_f - self.tolerance.to_f)..(val2.to_f + self.tolerance.to_f)
    elsif self.format == "date"
      if not val1.blank?
        val1.to_date >= val2.to_date - self.tolerance.days and
            val1.to_date <= val2.to_date + self.tolerance.days
      else
        false
      end
    elsif self.format == "current_month"
      val1.to_date.strftime('%Y-%m') == DateTime.now.strftime('%Y-%m')
    else
      val1 == val2
    end
  end
end
