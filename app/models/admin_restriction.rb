class AdminRestriction < ActiveRecord::Base
  serialize :restrictions, Array
  has_many :users

  validates_presence_of   :name
  validates_uniqueness_of :name
  validates_length_of     :name, :maximum => 30

  attr_accessible :name, :restrictions
end
