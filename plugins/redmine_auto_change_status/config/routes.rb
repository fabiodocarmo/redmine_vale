# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :auto_change_statuses
resources :auto_change_statuses do
  collection {post :import}
  collection {post :export_template}
end
