# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :external_validations

resources :calculate_value_base_with_iva_jobs, controller: :exec_jobs, type: 'CalculeValueBaseWithIvaJob'
resources :add_remove_deviation_job, controller: :exec_jobs, type: 'AddRemoveDeviationJob'

scope path: :cepom, as: :cepom do
  resources :cepom_rj_job, controller: :exec_jobs, type: 'Cepom::CepomRjJob'
end

post "external_validations_form/form" => "external_validations#form"
if Rails::VERSION::MAJOR < 4
  put  "external_validations_form/form" => "external_validations#form"
else
  patch  "external_validations_form/form" => "external_validations#form"
end
