# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :atribuicao_automaticas

resources :atribuicao_automaticas do
  collection {post :import}
  collection {post :export_template}
end
