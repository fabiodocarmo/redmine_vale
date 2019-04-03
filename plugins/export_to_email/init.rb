Redmine::Plugin.register :export_to_email do
  name 'Export to email'
  author 'Visagio'
  description ''
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  require_dependency 'issue'
  require 'hooks/mail_export_hook_listener'
end
