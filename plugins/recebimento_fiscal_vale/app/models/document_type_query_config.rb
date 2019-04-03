class DocumentTypeQueryConfig < ActiveRecord::Base
  unloadable

  belongs_to :status       , class_name: 'IssueStatus'

end
