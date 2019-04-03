# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :api_integrations

get 'custom_fields/:cf_id', :to => 'custom_fields#index', :cf_id => /\d+/
get 'issue_statuses/:status_id', :to => 'issue_statuses#index', :status_id => /\d+/
get 'possible_statuses/:issue_id', :to => 'issue_statuses#show', :status_id => /\d+/
post 'issues/:issue_id/copy', :to => 'issue_relations#create', :issue_id => /\d+/

post "api_integrations_form/form" => "api_integrations#form"
if Rails::VERSION::MAJOR < 4
 put  "api_integrations_form/form" => "api_integrations#form"
else
 patch  "api_integrations_form/form" => "api_integrations#form"
end