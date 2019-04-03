class EmailTemplate < ActiveRecord::Base

  attr_accessible :id,
  :template,
  :subject,
  :name,
  :image_url
end
