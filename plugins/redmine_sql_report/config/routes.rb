# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
resources :sql_reports
resources :project_sql_reports, only: [:index, :show]
get 'project_sql_reports/generate/:project_id/:id' => 'project_sql_reports#generate', as: 'generate_sql_report'
