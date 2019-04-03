class ExternalValidationQuery < ActiveRecord::Base
  unloadable

  belongs_to :external_validation
  belongs_to :custom_field
end
