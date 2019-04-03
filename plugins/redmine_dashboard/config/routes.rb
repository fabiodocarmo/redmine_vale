# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

scope '/admin' do
  resources :redmine_widgets, controller: 'admin_redmine_widgets'
  resources :dashboard_widgets, controller: 'admin_dashboard_widgets'
end

resources :dashboard_widgets, only: [:index] do
  resources :redmine_widgets, only: [:index]
end

post "dashboard/form" => "admin_redmine_widgets#form", as: :dashboard_upate_form
put "dashboard/form"  => "admin_redmine_widgets#form"

get "/dashboard/gestor_chamados/show_graph_values"   => "dashboard_widgets_settings#show_graph_values"

# Widgets
scope '/dashboard' do
  get ':controller/:action', as: :redmine_dashboard_widget
end
