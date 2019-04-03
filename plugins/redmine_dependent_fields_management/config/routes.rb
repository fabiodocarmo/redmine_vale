# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'dependent_fields/suggestions', to: 'dependent_fields#find_suggestion', as:  'suggestions_dependent_fields'
resources :dependent_fields do
  collection {post :import}
  collection {post :export_template}
end
