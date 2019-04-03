RedmineApp::Application.routes.draw do
  mount API::Root => '/'
end

match 'sso', :to => 'account#sso_login', :as => 'sso_login', :via => [:get]
