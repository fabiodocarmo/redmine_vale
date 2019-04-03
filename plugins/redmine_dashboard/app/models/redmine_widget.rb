class RedmineWidget < ActiveRecord::Base
  unloadable

  serialize :config, HashWithIndifferentAccess

  default_scope { order('dashboard_widget_id ASC, priority ASC') }

  belongs_to :dashboard_widget

  has_and_belongs_to_many :projects, :uniq => true
  has_and_belongs_to_many :custom_fields, :uniq => true
end
