# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get "/dashboard/gestor_chamados_vale/free_money" => "gestor_chamados_vale_dashboard#free_money"
get "/dashboard/gestor_chamados_vale/project_list" => "gestor_chamados_vale_dashboard#project_list"
get "/dashboard/gestor_chamados/answered_by_level" => "gestor_chamados_vale_dashboard#answered_by_level"
get "/dashboard/gestor_chamados/answered_by_level_sla" => "gestor_chamados_vale_dashboard#answered_by_level_sla"
get "/dashboard/gestor_chamados/aging_n1_n2" => "gestor_chamados_vale_dashboard#aging_n1_n2"
