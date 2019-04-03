Redmine::Plugin.register :sso_portal_integration do
  name 'Sso Portal Integration plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.1.2'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  require 'hooks/sso_user_hook_listener'

  settings default: {}, partial: 'settings/sso_settings'

  AccountController.send(:include, Patches::SsoAccountControllerPatch) unless AccountController.included_modules.include?(Patches::SsoAccountControllerPatch)
  AccountController.send(:include, Patches::SsoApplicationControllerPatch) unless ApplicationController.included_modules.include?(Patches::SsoApplicationControllerPatch)
  User.send(:include, Patches::SsoUserPatch) unless User.included_modules.include?(Patches::SsoUserPatch)

end
