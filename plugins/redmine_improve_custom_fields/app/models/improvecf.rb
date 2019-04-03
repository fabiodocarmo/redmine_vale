class Improvecf < ActiveRecord::Base
  self.abstract_class = true
  self.table_name_prefix = 'improvecf_'

  MASK = [:cpf_cnpj, :cep, :phone, :br_numeric, :car,:time, :password, :teste,:custom]
end
