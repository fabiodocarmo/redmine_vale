# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get '/export_to_vale_invoice_robot/index' => 'export_to_vale_invoice_robot#index'
post '/export_to_vale_invoice_robot/create' => 'export_to_vale_invoice_robot#create'
post '/export_to_vale_invoice_robot/update' => 'export_to_vale_invoice_robot#update'

get '/export_to_vale_utilities_robot/index' => 'export_to_vale_utilities_robot#index'
post '/export_to_vale_utilities_robot/create' => 'export_to_vale_utilities_robot#create'
post '/export_to_vale_utilities_robot/update' => 'export_to_vale_utilities_robot#update'

get '/export_to_vale_transmission_companies_robot/index' => 'export_to_vale_transmission_companies_robot#index'
post '/export_to_vale_transmission_companies_robot/create' => 'export_to_vale_transmission_companies_robot#create'
post '/export_to_vale_transmission_companies_robot/update' => 'export_to_vale_transmission_companies_robot#update'

get '/export_to_vale_telecom_companies_robot/index' => 'export_to_vale_telecom_companies_robot#index'
post '/export_to_vale_telecom_companies_robot/create' => 'export_to_vale_telecom_companies_robot#create'
post '/export_to_vale_telecom_companies_robot/update' => 'export_to_vale_telecom_companies_robot#update'

get '/export_to_vale_nfse_robot/index' => 'export_to_vale_nfse_robot#index'
post '/export_to_vale_nfse_robot/create' => 'export_to_vale_nfse_robot#create'
post '/export_to_vale_nfse_robot/update_ok' => 'export_to_vale_nfse_robot#update_ok'
post '/export_to_vale_nfse_robot/update_error' => 'export_to_vale_nfse_robot#update_error'

get '/export_to_vale_danfe_companies_robot/index' => 'export_to_vale_danfe_companies_robot#index'
post '/export_to_vale_danfe_companies_robot/create' => 'export_to_vale_danfe_companies_robot#create'
post '/export_to_vale_danfe_companies_robot/update' => 'export_to_vale_danfe_companies_robot#update'

get '/export_to_vale_grc_robot/index' => 'export_to_vale_grc_robot#index'
post '/export_to_vale_grc_robot/import_grc_report' => 'export_to_vale_grc_robot#import_grc_report'
post '/export_to_vale_grc_robot/update_ok' => 'export_to_vale_grc_robot#update_grc_robot_ok'
post '/export_to_vale_grc_robot/update_error' => 'export_to_vale_grc_robot#update_grc_robot_error'
post '/export_to_vale_grc_robot/update_send_to_nfse_robot' => 'export_to_vale_grc_robot#update_send_to_nfse_robot'

get '/export_to_vale_cte_os_robot/index' => 'export_to_vale_cte_os_robot#index'
post '/export_to_vale_cte_os_robot/create' => 'export_to_vale_cte_os_robot#create'
post '/export_to_vale_cte_os_robot/update_ok' => 'export_to_vale_cte_os_robot#update_ok'
post '/export_to_vale_cte_os_robot/update_error' => 'export_to_vale_cte_os_robot#update_error'

get '/export_to_vale_danfe_nfse_robot/index' => 'export_to_vale_danfe_nfse_robot#index'
post '/export_to_vale_danfe_nfse_robot/create' => 'export_to_vale_danfe_nfse_robot#create'
post '/export_to_vale_danfe_nfse_robot/update_ok' => 'export_to_vale_danfe_nfse_robot#update_ok'
post '/export_to_vale_danfe_nfse_robot/update_error' => 'export_to_vale_danfe_nfse_robot#update_error'

get '/export_to_vale_priorities_robot/index' => 'export_to_vale_priorities_robot#index'
post '/export_to_vale_priorities_robot/create' => 'export_to_vale_priorities_robot#create'
post '/export_to_vale_priorities_robot/update' => 'export_to_vale_priorities_robot#update'
post '/export_to_vale_priorities_robot/update_error' => 'export_to_vale_priorities_robot#update_error'

get '/export_to_vale_rpa_robot/index' => 'export_to_vale_rpa_robot#index'
post '/export_to_vale_rpa_robot/create' => 'export_to_vale_rpa_robot#create'
post '/export_to_vale_rpa_robot/update' => 'export_to_vale_rpa_robot#update'
post '/export_to_vale_rpa_robot/update_error' => 'export_to_vale_rpa_robot#update_error'

get '/export_to_vale_rents_robot/index' => 'export_to_vale_rents_robot#index'
post '/export_to_vale_rents_robot/create' => 'export_to_vale_rents_robot#create'
post '/export_to_vale_rents_robot/update' => 'export_to_vale_rents_robot#update'
post '/export_to_vale_rents_robot/update_error' => 'export_to_vale_rents_robot#update_error'

get '/export_to_vale_measurement_robot/index' => 'export_to_vale_measurement_robot#index'
post '/export_to_vale_measurement_robot/create' => 'export_to_vale_measurement_robot#create'
post '/export_to_vale_measurement_robot/update' => 'export_to_vale_measurement_robot#update'
post '/export_to_vale_measurement_robot/update_error' => 'export_to_vale_measurement_robot#update_error'

get '/export_to_vale_measurement2_robot/index' => 'export_to_vale_measurement2_robot#index'
post '/export_to_vale_measurement2_robot/create' => 'export_to_vale_measurement2_robot#create'
post '/export_to_vale_measurement2_robot/update' => 'export_to_vale_measurement2_robot#update'
post '/export_to_vale_measurement2_robot/update_error' => 'export_to_vale_measurement2_robot#update_error'