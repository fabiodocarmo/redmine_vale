class ImportTemplate < ActiveRecord::Base
  unloadable

  belongs_to :user
  serialize :settings
end
