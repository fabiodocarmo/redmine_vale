class BusinessRule < ActiveRecord::Base
  unloadable

  serialize :parameters

  PARAMETER_TYPES = {
      string: lambda { |parameter| parameter.to_s },
      int: lambda { |parameter| parameter.to_s.to_i },
      float: lambda { |parameter| parameter.to_s.to_f }
  }

  PARAMETER_KEYS = Set.new [:type, :value]

  CUSTOM_FIELD_VALUE_EXPRESSION = /#\{cf\_([1-9][0-9]*)}/   # ex: #{cf_15}
  ARRAY_ACESS_EXPRESSION = /\[-?\d+(\.\.-?\d+)?\]/          # exs: [1], [-3], [0..-1]

  FORBIDDEN_EXPRESSION = '¬¬¬¬'

  ALLOWED_EXPRESSIONS = [
      CUSTOM_FIELD_VALUE_EXPRESSION, ARRAY_ACESS_EXPRESSION,
      '?', '<', '>', '=', '!', '&', '|'
  ]


  validates_presence_of :rule
  validate :validate_parameters_count, :validate_parameters_types, :validate_parameters_format
  validate :validate_rule_allowed_expressions

  def evaluate_rule(issue)
    raise 'Cannot evaluate invalid rule' unless valid?

    eval(parse_rule(issue))
  end

  private

  def parse_rule(issue)
    parsed_rule = self.rule
    parsed_rule = parse_parameters(parsed_rule, self.parameters)
    parsed_rule = parse_custom_field_values(parsed_rule, issue)
    parsed_rule
  end

  def parse_parameters(parsing_rule, params)
    return parsing_rule if params.blank?
    
    params.reduce(parsing_rule) do |acc, el|
      acc.sub('?', PARAMETER_TYPES[el[:type]].call(el[:value]).to_json)
    end
  end

  def parse_custom_field_values(parsing_rule, issue)
    parsing_rule.gsub(CUSTOM_FIELD_VALUE_EXPRESSION) do |exp|
      cv = issue.custom_field_values.detect { |cfv| cfv.custom_field.id == $1.to_i }

      if cv.present?
        cv.custom_field.format.cast_custom_value(cv).to_json
      else
        'nil'
      end
    end
  end

  def validate_parameters_count
    parameters_size = (parameters || []).count
    parameters_expected_size = (rule || '').count('?')

    if parameters_size != parameters_expected_size
      errors.add(:parameters, :wrong_number_of_parameters, {
          actual_size: parameters_size, expected_size: parameters_expected_size
      })
    end
  end

  def validate_parameters_types
    return true if self.parameters.blank?

    a = self.parameters.reduce(Set.new) { |acc, el| acc << el[:type] }
    b = PARAMETER_TYPES.keys.to_set

    if !(a.subset? b)
      errors.add(:parameters, :invalid_parameter_type, { allowed_types: b.to_a.to_s })
    end
  end

  def validate_parameters_format
    return true if self.parameters.blank?

    self.parameters.each do |param|
      unless param.is_a?(Hash) && param.keys.to_set == (PARAMETER_KEYS)
        errors.add(:parameters, :invalid_parameter_format, { allowed_keys: PARAMETER_KEYS.to_a.to_s})

        return false
      end
    end
  end

  def validate_rule_allowed_expressions
    return false if rule.blank?

    validated_rule = ALLOWED_EXPRESSIONS.reduce(rule) do |acc, expression|
      acc.gsub(expression, FORBIDDEN_EXPRESSION)
    end

    validated_rule.delete!(FORBIDDEN_EXPRESSION)

    errors.add(:rule, :rule_invalid_expressions) unless validated_rule.blank?
  end

end
