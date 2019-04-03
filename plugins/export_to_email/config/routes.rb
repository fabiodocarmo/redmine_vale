# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get "/issues/export_to_email/export_csv" => "mailer#export_to_email", as: 'export_to_email'
