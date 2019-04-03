Redmine::Plugin.register :redmine_block_duplicate do
  name 'Redmine Block Duplicate plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  menu :admin_menu, :block_duplicates, { controller: 'block_duplicates', action: 'index' }
  Issue.send(:include, RedmineBlockDuplicate::Patches::IssuePatch) unless Issue.included_modules.include? RedmineBlockDuplicate::Patches::IssuePatch
  CustomValue.send(:include, RedmineBlockDuplicate::Patches::CustomValuePatch) unless CustomValue.included_modules.include?(RedmineBlockDuplicate::Patches::CustomValuePatch)
end
