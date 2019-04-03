class CreateDivergenceBusinessRules < ActiveRecord::Migration
  def change
    DivergenceBusinessRule.create(rule: '?', parameters: [{ type: :string, value: '1'}])
    DivergenceBusinessRule.create(rule: '?', parameters: [{ type: :string, value: '2'}])
    DivergenceBusinessRule.create(rule: '?', parameters: [{ type: :string, value: '5'}])
    DivergenceBusinessRule.create(rule: '?', parameters: [{ type: :string, value: '7'}])
    DivergenceBusinessRule.create(rule: '?', parameters: [{ type: :string, value: '18'}])
    DivergenceBusinessRule.create(rule: '?', parameters: [{ type: :string, value: '25'}])
    DivergenceBusinessRule.create(rule: '?', parameters: [{ type: :string, value: '102'}])
    DivergenceBusinessRule.create(rule: '?', parameters: [{ type: :string, value: '105'}])
    DivergenceBusinessRule.create(rule: '?', parameters: [{ type: :string, value: '111'}])
    DivergenceBusinessRule.create(rule: '?', parameters: [{ type: :string, value: '114'}])
    DivergenceBusinessRule.create(rule: '?', parameters: [{ type: :string, value: '115'}])
    DivergenceBusinessRule.create(rule: '?', parameters: [{ type: :string, value: '119'}])
    DivergenceBusinessRule.create(rule: '?', parameters: [{ type: :string, value: '128'}])
    DivergenceBusinessRule.create(rule: '?', parameters: [{ type: :string, value: '129'}])
  end
end
