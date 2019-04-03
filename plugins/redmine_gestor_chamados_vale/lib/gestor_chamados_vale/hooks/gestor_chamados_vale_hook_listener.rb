class GestorChamadosValeHookListener < Redmine::Hook::ViewListener
  render_on :view_trackers_form_details, :partial => 'trackers/tracker_value_fields'
end
