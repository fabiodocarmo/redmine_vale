class SsoUserHookListener < Redmine::Hook::ViewListener

	render_on :user_list_options, :partial => 'users/disable_add_user'
  render_on :view_users_form, :partial => 'users/disable_user_edition'
  render_on :view_group_tabs, :partial => 'groups/disable_modify_users'
  render_on :view_my_account, :partial => 'my/disable_user_edition'
end
