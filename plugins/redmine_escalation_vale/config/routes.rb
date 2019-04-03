# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

match 'notifications/sender', controller: 'notifications',  action: 'sender', via: [:get]
resources :notifications
resources :visibility_reports do
  collection {post :export_template}
end
resources :hierarchies do
  collection {post :export_template}
end
resources :email_templates
resources :escalation
resources :rules do
  collection {post :import}
  collection {post :export_template}
end
