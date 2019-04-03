class DependentField < ActiveRecord::Base
  unloadable

  attr_protected :avaliable, :dependent_type, :project_id, :main_field_id,
                 :main_field_value, :secondary_field_id, :not_nullable,
                 :secondary_field_value, as: :admin

  belongs_to :project
  belongs_to :tracker
  belongs_to :main_field, class_name: 'CustomField', foreign_key: 'main_field_id'
  belongs_to :secondary_field, class_name: 'CustomField', foreign_key: 'secondary_field_id'

  scope :available, -> { where(avaliable: true) }
  scope :value_rules, -> { where(dependent_type: 'value') }
  scope :by_tracker_id_and_project_id_and_main_field_ids, lambda { |t, p, mf|
      includes(:main_field, :secondary_field)
          .where(tracker_id: t)
          .where(project_id: p)
          .where(main_field_id: mf)
  }


  DEPENDENT_TYPE = {
    visibility: l("dependent_type_visibility"),
    value: l("dependent_type_value"),
    sugestion: l("dependent_type_sugestion")
  }.with_indifferent_access

  def available_custom_fields
    CustomField.where("type = 'IssueCustomField'").sorted.all
  end


  def self.main_custom_value_condition(custom_field_values)
    condition = "("
    custom_field_values.each do |cv|
      if cv.value.is_a? Array
        condition += ActiveRecord::Base.send(:sanitize_sql_array,
                    ["(main_field_id = ? and main_field_value in (?)) or ", cv.custom_field_id, cv.value])
      else
        condition += ActiveRecord::Base.send(:sanitize_sql_array,
                    ["(main_field_id = ? and main_field_value = ?) or ", cv.custom_field_id, cv.value.to_s])
      end
    end
    condition += "1 = 2)"
  end
end
