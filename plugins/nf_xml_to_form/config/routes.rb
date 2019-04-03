# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :nf_xml, only: [:create, :show]
get '/nf_xml', to: 'nf_xml#index', as: :nf_to_xml
get '/csv_converter', to: 'csv_converter#index', as: :csv_converter
post '/csv_converter', to: 'csv_converter#convert'

resources :due_date_jobs                                      , controller: :exec_jobs, type: 'DueDateJob'
resources :validate_emission_date_greater_than_created_on_jobs, controller: :exec_jobs, type: 'ValidateEmissionDateGreaterThanCreatedOnJob'
resources :validate_initial_date_greater_than_end_date_jobs   , controller: :exec_jobs, type: 'ValidateInitialDateGreaterThanEndDateJob'
resources :validate_tax_rate_and_value_job                    , controller: :exec_jobs, type: 'ValidateEmissionDateGreaterThanCreatedOnJob'
resources :validate_authorship_indicative_job                 , controller: :exec_jobs, type: 'ValidateAuthorshipIndicativeJob'
resources :calculate_taxes_base_value_jobs                    , controller: :exec_jobs, type: 'CalculateTaxesBaseValueJob'
resources :format_posting_date_jobs                           , controller: :exec_jobs, type: 'FormatPostingDateJob'
resources :auto_forward_issue_to_grc_job                      , controller: :exec_jobs, type: 'AutoForwardIssueToGrcJob'
resources :auto_forward_issue_to_robot_job                    , controller: :exec_jobs, type: 'AutoForwardIssueToRobotJob'
resources :validate_withheld_tax_job                          , controller: :exec_jobs, type: 'ValidateWithheldTaxJob'
resources :email_to_nf_job                                    , controller: :exec_jobs, type: 'EmailToNfJob'
