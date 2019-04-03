# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get "/dashboard/gestor_chamados/customer_by_issue_number"                     => "gestor_chamados_dashboard#customer_by_issue_number"
get "/dashboard/gestor_chamados/customer_by_issue_number_total"               => "gestor_chamados_dashboard#customer_by_issue_number_total"
get "/dashboard/gestor_chamados/customer_by_issue_number_list"                => "gestor_chamados_dashboard#customer_by_issue_number_list"
get "/dashboard/gestor_chamados/customer_by_issue_number_monthly_progress"    => "gestor_chamados_dashboard#customer_by_issue_number_monthly_progress"
get "/dashboard/gestor_chamados/customer_by_reopened_issues"                  => "gestor_chamados_dashboard#customer_by_reopened_issues"
get "/dashboard/gestor_chamados/project_list"                                 => "gestor_chamados_dashboard#project_list"
get "/dashboard/gestor_chamados/customer_by_issue_value"                      => "gestor_chamados_dashboard#customer_by_issue_value"
get "/dashboard/gestor_chamados/customer_by_issue_value_total"                => "gestor_chamados_dashboard#customer_by_issue_value_total"
get "/dashboard/gestor_chamados/customer_by_issue_value_list"                 => "gestor_chamados_dashboard#customer_by_issue_value_list"
get "/dashboard/gestor_chamados/customer_by_issue_value_monthly_progress"     => "gestor_chamados_dashboard#customer_by_issue_value_monthly_progress"
get "/dashboard/gestor_chamados/weekly_progress_by_contact"                   => "gestor_chamados_dashboard#weekly_progress_by_contact"
get "/dashboard/gestor_chamados/new_by_tracker_by_contact"                    => "gestor_chamados_dashboard#new_by_tracker_by_contact"
get "/dashboard/gestor_chamados/wrong_issues_per_project"                     => "gestor_chamados_dashboard#wrong_issues_per_project"
get "/dashboard/gestor_chamados/resolver_areas"                               => "gestor_chamados_dashboard#resolver_areas"
