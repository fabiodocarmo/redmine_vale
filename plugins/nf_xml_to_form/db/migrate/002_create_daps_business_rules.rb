class CreateDapsBusinessRules < ActiveRecord::Migration
  def up
    #Empresa Vale
    DapsBusinessRule.create(rule: '#{cf_1054} == ? && #{cf_1094}[0..7] == ? && #{cf_1050} != #{cf_1054}', parameters: [{ type: :string, value: '3200102'}, { type: :string, value: '33592510'       }]) # Afonso Claudio
    DapsBusinessRule.create(rule: '#{cf_1054} == ? && #{cf_1094}[0..7] == ? && #{cf_1050} != #{cf_1054}', parameters: [{ type: :string, value: '3200805'}, { type: :string, value: '33592510'       }]) # Baixo Guandu
    DapsBusinessRule.create(rule: '#{cf_1054} == ? && #{cf_1094}[0..7] == ? && #{cf_1050} != #{cf_1054}', parameters: [{ type: :string, value: '3201506'}, { type: :string, value: '33592510'       }]) # Colatina
    DapsBusinessRule.create(rule: '#{cf_1054} == ? && #{cf_1094}[0..7] == ? && #{cf_1050} != #{cf_1054}', parameters: [{ type: :string, value: '3202504'}, { type: :string, value: '33592510'       }]) # Ibiraçu
    DapsBusinessRule.create(rule: '#{cf_1054} == ? && #{cf_1094}[0..7] == ? && #{cf_1050} != #{cf_1054}', parameters: [{ type: :string, value: '3203130'}, { type: :string, value: '33592510'       }]) # João Neiva
    DapsBusinessRule.create(rule: '#{cf_1054} == ? && #{cf_1094}[0..7] == ? && #{cf_1050} != #{cf_1054}', parameters: [{ type: :string, value: '3203205'}, { type: :string, value: '33592510'       }]) # Linhares

    #Empresa Vale Manganês
    DapsBusinessRule.create(rule: '#{cf_1054} == ? && #{cf_1094} == ? && #{cf_1050} != #{cf_1054}'      , parameters: [{ type: :string, value: '2930709'}, { type: :string, value: '15144306000199' }]) # Simões Filho
  end

  def down
    DapsBusinessRule.destroy_all
  end
end
