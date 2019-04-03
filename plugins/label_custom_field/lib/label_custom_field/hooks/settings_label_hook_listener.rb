module LabelCustomFieldHookListeners
	class SettingsLabelHookListener < Redmine::Hook::ViewListener

		render_on :view_custom_fields_form_upper_box, :partial => 'custom_fields/header_wikitoolbar'

	end
end
