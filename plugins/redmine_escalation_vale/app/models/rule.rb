class Rule < ActiveRecord::Base
  belongs_to :email_template, :class_name => 'EmailTemplate'
  attr_accessible :id, :min_sent, :max_sent, :area, :hierarchy, :classification, :email_template_id
end
