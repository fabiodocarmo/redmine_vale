module DashboardChartsGestorChamados
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc
        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development

          scope :find_customer, -> (cnpj_cpf) do
            joins(:custom_values)
            .where(custom_values: {custom_field_id: Setting.plugin_redmine_gestor_chamadas[:customer_field]})
            .where('case
                      when (length(custom_values.value) = 14)
                        then mid(custom_values.value, 1, 8)
                      else
                        custom_values.value
                      end = ?', cnpj_cpf)
          end

          scope :group_customers_by_cnpj_cpf, -> do
            joins('INNER JOIN `custom_values` customer_field ON customer_field.`customized_id` = `issues`.`id`
                    AND customer_field.`customized_type` = \'Issue\'')
            .where('customer_field.custom_field_id = ?', Setting.plugin_redmine_gestor_chamadas[:customer_field])
            .where('customer_field.value is not null')
            .group('case
                      when (length(customer_field.value) = 14)
                        then mid(customer_field.value, 1, 8)
                      else
                        customer_field.value
                      end')
          end

          scope :find_social_name, -> do
            joins('INNER JOIN `custom_values` social_name ON social_name.`customized_id` = `issues`.`id`
                    AND social_name.`customized_type` = \'Issue\'')
            .where('social_name.custom_field_id = ?', Setting.plugin_redmine_gestor_chamadas[:social_name])
            .where('social_name.value is not null')
          end

          scope :find_values, -> do
            joins('INNER JOIN `custom_values` value_field ON value_field.`customized_id` = `issues`.`id`
                    AND value_field.`customized_type` = \'Issue\'')
            .where(value_field: {custom_field_id: CustomField.where(value_field: true).select(:id)})
            .where('value_field.id is not null')
          end

        end
      end
    end
  end
end
