Redmine::Plugin.register :recebimento_fiscal_vale do
  name 'Recebimento Fiscal Vale plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  settings default: {}, partial: 'settings/recebimento_fiscal_vale'

  menu :admin_menu, :recebimento_fiscal_vale, { controller: 'document_type_queries', action: 'index' }

  Issue.send(:include, RecebimentoFiscalVale::Patches::IssuePatch) unless Issue.included_modules.include? RecebimentoFiscalVale::Patches::IssuePatch
end

Rails.configuration.after_initialize do
  StatusChangeJob.register
  OrderTypeJob.register
  RetentionJob.register
end