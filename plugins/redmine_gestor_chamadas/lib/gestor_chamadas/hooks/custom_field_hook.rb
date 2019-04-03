class GestorChamadas::Hooks::CustomFieldHook < Redmine::Hook::ViewListener
  def view_custom_fields_form_issue_custom_field(params)
    "<p>#{params[:form].check_box :dont_copy}</p>"
    "<p>#{params[:form].check_box :value_field}</p>"
  end
end
