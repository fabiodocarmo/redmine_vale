# encoding: UTF-8
module Patches
  module ConsultaIssuePatch
    def self.included(base) # :nodoc
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
    end


  def show_url_nf?
    has_valid_cpf_cnpj?
  end

  def show_url_deposito?
    self.tracker == Tracker.where(name:'Identificação de depósito').first
  end

  def has_valid_nf?
    return false unless (@nf = nf_number)
    nf_number.to_i && (@nf.to_i.to_s.length == @nf.length)
  end

  def nf_number
    @custom_field_nf = CustomField.find(Setting.plugin_consulta_unificada[:nf_custom_field].to_i)
    return false unless Tracker.joins(:custom_fields).joins(:issues).where(issues:{id:self}).where(custom_fields:{id:@custom_field_nf}).first
    CustomValue.where(customized_type:'Issue').where(customized_id:self).where(custom_field_id:@custom_field_nf).first.try(:value)
  end

  module InstanceMethods
  end

  module ClassMethods
  end

  end
end
