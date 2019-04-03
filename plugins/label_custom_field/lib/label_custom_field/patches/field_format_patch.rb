class LabelFormat < Redmine::FieldFormat::Unbounded
  include Redmine::FieldFormat
  include ApplicationHelper
  include ActionView::Helpers::SanitizeHelper

  add 'label'
  self.form_partial = 'custom_fields/formats/label'

  def self.name_id
    'label'
  end

  def formatted_value(view, custom_field, value, customized=nil, html=false)
    show_label_value(view, custom_field)
  end

  def edit_tag(view, tag_id, tag_name, custom_value, options={})
    show_label_value(view, custom_value.custom_field)
  end

  private

  def show_label_value(view, custom_field)
    textilizable(custom_field.default_value)
  end

end
