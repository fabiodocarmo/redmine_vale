# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :exec_jobs do
  collection {post :import}
  collection {post :export_template}
end

resources :example_exec_jobs, controller: :exec_jobs, type: 'ExampleExecJob'
