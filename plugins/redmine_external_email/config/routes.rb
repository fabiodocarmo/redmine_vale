# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :redmine_external_emails do
  collection {post :import}
  collection {post :export_template}
end
