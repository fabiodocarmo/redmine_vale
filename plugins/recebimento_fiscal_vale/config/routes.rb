# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :document_type_queries
resources :status_change_jobs, controller: :exec_jobs, type: 'StatusChangeJob'
resources :order_type_jobs, controller: :exec_jobs, type: 'OrderTypeJob'
resources :retention_jobs, controller: :exec_jobs, type: 'RetentionJob'

post "document_type_queries_form/form" => "document_type_queries#form"
if Rails::VERSION::MAJOR < 4
  put  "document_type_queries_form/form" => "document_type_queries#form"
else
  patch  "document_type_queries_form/form" => "document_type_queries#form"
end
