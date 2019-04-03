# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :nf_statuses
get "/consulta_unificada/nf_status" => "consulta_unificada#nf_status", as: 'get_nf_status'

get "/consulta_unificada/retrieve_url_to_consultanf/:issue" => "consulta_unificada#retrieve_url_to_consultanf", as: 'retrieve_url_to_consultanf'

#get  "/consultanf.json" => "consulta_unificada#consultanf_notas", as: 'consultanf_notas'
post "/consultanf.json" => "consulta_unificada#consultanf_notas", as: 'consultanf_notas'
