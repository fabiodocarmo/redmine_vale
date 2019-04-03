# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get "/dashboard/gestor_chamados/new_by_project"    => "dashboard_charts#new_by_project"

get "/dashboard/gestor_chamados/aging_tracker"   => "dashboard_charts#aging_tracker"
get "/dashboard/gestor_chamados/aging_project"   => "dashboard_charts#aging_project"
get "/dashboard/gestor_chamados/aging_per_atendent" => "dashboard_charts#aging_per_atendent"
get "/dashboard/gestor_chamados/aging_has_atendent" => "dashboard_charts#aging_has_atendent"

get "/dashboard/gestor_chamados/performance_per_fte" => "dashboard_charts#performance_per_fte"
get "/dashboard/gestor_chamados/assigned_list" => "dashboard_charts#assigned_list"
get "/dashboard/gestor_chamados/assigned_list_per_group" => "dashboard_charts#assigned_list_per_group"

get "/dashboard/gestor_chamados/project_average_answer_time/"              => "dashboard_charts#projects_average_answer_time"
get "/dashboard/gestor_chamados/project_average_answer_time/:id"           => "dashboard_charts#project_average_answer_time"
get "/dashboard/gestor_chamados/projects_list"                             => "dashboard_charts#projects_list"
get "/dashboard/gestor_chamados/performance_by_project" => "dashboard_charts#performance_by_project"
