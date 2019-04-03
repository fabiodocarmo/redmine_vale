# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

scope '/vsg_sla' do
  resources :office_hours, as: :vsg_sla_office_hours
  resources :slas, as: :vsg_sla_slas

  resources :slas_settings, only: [:index], as: :vsg_sla_slas_settings
  resources :sla_reports  , only: [:index], as: :vsg_sla_sla_reports

  post "office_hours/form" => "office_hours#form"
  if Rails::VERSION::MAJOR < 4
    put  "office_hours/form" => "office_hours#form"
  else
    patch  "office_hours/form" => "office_hours#form"
  end

  post "vsg_sla_slas_form/form" => "slas#form"
  if Rails::VERSION::MAJOR < 4
    put  "vsg_sla_slas_form/form" => "slas#form"
  else
    patch  "vsg_sla_slas_form/form" => "slas#form"
  end
end
