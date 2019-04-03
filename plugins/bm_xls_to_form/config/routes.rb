# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :bm_xls, only: [:create, :show]
get '/bm_xls', to: 'bm_xls#index', as: :bm_to_xls
get '/req_to_pay_upload', to: 'req_to_pay_upload#index', as: :req_to_pay_upload
post '/req_to_pay_upload', to: 'req_to_pay_upload#upload'

resources :bm_status_change_job, controller: :exec_jobs, type: 'BMStatusChageJob'