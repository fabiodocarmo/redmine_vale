class CpfCnpj < ActiveRecord::Base
  unloadable

  belongs_to :contact
end
