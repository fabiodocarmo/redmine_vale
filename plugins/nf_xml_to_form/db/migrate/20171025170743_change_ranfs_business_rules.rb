class ChangeRanfsBusinessRules < ActiveRecord::Migration
  def up
    RanfsBusinessRule.destroy_all

    RanfsBusinessRule.create(rule: '#{cf_1054} == ? && #{cf_1050} != #{cf_1054}', parameters: [{ type: :string, value: '2800308'}]) # Aracaju
    RanfsBusinessRule.create(rule: '#{cf_1054} == ? && #{cf_1094} == ? && #{cf_1050} != #{cf_1054}', parameters: [{ type: :string, value: '3155702'}, { type: :string, value: '33592510041349' }]) # Rio Piracicaba
    RanfsBusinessRule.create(rule: '#{cf_1054} == ? && #{cf_1050} != #{cf_1054}', parameters: [{ type: :string, value: '3161908'}]) # São Gonçalo do Rio Abaixo
    RanfsBusinessRule.create(rule: '#{cf_1054} == ? && #{cf_1050} != #{cf_1054}', parameters: [{ type: :string, value: '3205101'}]) # Viana
    RanfsBusinessRule.create(rule: '#{cf_1054} == ? && #{cf_1050} != #{cf_1054}', parameters: [{ type: :string, value: '3157203'}]) # Santa Barbara
    RanfsBusinessRule.create(rule: '#{cf_1054} == ? && #{cf_1050} != #{cf_1054}', parameters: [{ type: :string, value: '3170107'}]) # Uberaba
    RanfsBusinessRule.create(rule: '#{cf_1054} == ? && #{cf_1050} != #{cf_1054}', parameters: [{ type: :string, value: '3105608'}]) # Barbacena
  end

  def down
    RanfsBusinessRule.destroy_all

    #Empresa Vale
    RanfsBusinessRule.create(rule: '#{cf_1054} == ? && #{cf_1094} == ? && #{cf_1050} != #{cf_1054}'      , parameters: [{ type: :string, value: '2800308'}, { type: :string, value: '33592510012403' }]) # Aracaju
    RanfsBusinessRule.create(rule: '#{cf_1054} == ? && #{cf_1094} == ? && #{cf_1050} != #{cf_1054}'      , parameters: [{ type: :string, value: '3155702'}, { type: :string, value: '33592510041349' }]) # Rio Piracicaba
    RanfsBusinessRule.create(rule: '#{cf_1054} == ? && #{cf_1094} == ? && #{cf_1050} != #{cf_1054}'      , parameters: [{ type: :string, value: '3161908'}, { type: :string, value: '33592510044798' }]) # São Gonçalo do Rio Abaixo
    RanfsBusinessRule.create(rule: '#{cf_1054} == ? && #{cf_1094} == ? && #{cf_1050} != #{cf_1054}'      , parameters: [{ type: :string, value: '3205101'}, { type: :string, value: '33592510002106' }]) # Viana
    RanfsBusinessRule.create(rule: '#{cf_1054} == ? && #{cf_1094}[0..7] == ? && #{cf_1050} != #{cf_1054}', parameters: [{ type: :string, value: '3157203'}, { type: :string, value: '33592510'       }]) # Santa Barbara
    RanfsBusinessRule.create(rule: '#{cf_1054} == ? && #{cf_1094}[0..7] == ? && #{cf_1050} != #{cf_1054}', parameters: [{ type: :string, value: '3170107'}, { type: :string, value: '33592510'       }]) # Uberaba

    #Empresa Vale Manganês
    RanfsBusinessRule.create(rule: '#{cf_1054} == ? && #{cf_1094} == ? && #{cf_1050} != #{cf_1054}'      , parameters: [{ type: :string, value: '3105608'}, { type: :string, value: '15144306000199' }]) # Barbacena
  end
end
