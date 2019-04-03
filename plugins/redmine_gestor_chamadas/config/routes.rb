# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :gestor_chamados_tickets, only: [:new, :create]
resources :gestor_chamados_projects, only: [:index]
resources :gestor_chamados_faq, only: [:index]
resources :satisfaction_questions

resources :satisfaction_questions do
  collection {post :import}
  collection {post :export_template}
end

resources :faq_links

match 'gestor_chamados_tickets/confirmation_ticket/:id/:token',
      controller: 'gestor_chamados_tickets',
      action: 'confirmation_ticket', via: [:get],
      as: 'gestor_chamados_confirmation_ticket'

match 'gestor_chamados_tickets/update_form',
      controller: 'gestor_chamados_tickets',
      action: 'new', via: [:post]

resources :satisfaction_surveys, only: [:create]

get "/satisfaction_surveys/:id", to: 'satisfaction_surveys#show', as: 'show_satisfaction_survey'
post "/satisfaction_surveys/create/:issue_id", to: 'satisfaction_surveys#create', as: 'create_satisfaction_survey'
get "/satisfaction_surveys/new/:issue_id/:error", to: 'satisfaction_surveys#new', as: 'new_satisfaction_survey'

get "/gestor_chamados_vale_dashboard/archive_issue/:id&:user" => "gestor_chamados_archive#archive_issue", as: 'archive_issue'

resources :validate_issue_id_field_jobs , controller: :exec_jobs, type: 'ValidateIssueIdFieldJob'
