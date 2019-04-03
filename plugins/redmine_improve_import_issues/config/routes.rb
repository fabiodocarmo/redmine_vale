match '/imports/:id/xlsx', :to => 'imports#xlsx', :via => [:get, :post], :as => 'import_xlsx'

post "import_issues_form/form" => "imports#form"
if Rails::VERSION::MAJOR < 4
  put  "import_issues_form/form" => "imports#form"
else
  patch  "import_issues_form/form" => "imports#form"
end
