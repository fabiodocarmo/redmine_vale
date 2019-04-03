class Hierarchy < ActiveRecord::Base
  unloadable

  belongs_to :user, :class_name => 'User'
  belongs_to :n1, :class_name => 'User'
  belongs_to :n2, :class_name => 'User'
  belongs_to :n3, :class_name => 'User'
  belongs_to :n4, :class_name => 'User'
  belongs_to :n5, :class_name => 'User'
  belongs_to :n6, :class_name => 'User'
  belongs_to :n7, :class_name => 'User'
  belongs_to :n8, :class_name => 'User'

  attr_protected :id,
  :user_id,
  :n1_id,
  :n2_id,
  :n3_id,
  :n4_id,
  :n5_id,
  :n6_id,
  :n7_id,
  :n8_id,
  :hierarchy_level

end
