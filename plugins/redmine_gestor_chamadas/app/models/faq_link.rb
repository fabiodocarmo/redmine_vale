class FaqLink < ActiveRecord::Base
  unloadable
  belongs_to :tracker
end
