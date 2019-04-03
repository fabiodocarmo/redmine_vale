Redmine::Plugin.register :form_to_xml do
  name 'Form To Xml plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  settings default: {}, :partial => 'settings/form_to_xml'

end

Rails.configuration.after_initialize do
  FormToXmlJob.register
  XmlToEmailJob.register
end
