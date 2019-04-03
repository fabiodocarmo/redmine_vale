class VsgSla < ActiveRecord::Base
  self.abstract_class = true
  self.table_name_prefix = 'vsg_sla_'
end
