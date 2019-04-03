# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :approvals do
  collection {post :import}
  collection {post :export_template}
end
