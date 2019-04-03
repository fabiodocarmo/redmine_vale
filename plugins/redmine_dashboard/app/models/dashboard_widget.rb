class DashboardWidget < ActiveRecord::Base
  unloadable
  default_scope { order('priority ASC') }

  has_many :redmine_widget, dependent: :destroy
end
