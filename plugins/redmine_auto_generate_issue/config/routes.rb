# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :auto_issues
resources :schedule_auto_issues  , controller: :auto_issues, type: 'ScheduleAutoIssue'
resources :status_auto_issues    , controller: :auto_issues, type: 'StatusAutoIssue'
resources :recurrent_auto_issues , controller: :auto_issues, type: 'RecurrentAutoIssue'
resources :attachment_auto_issues, controller: :auto_issues, type: 'AttachmentAutoIssue'

post "auto_issues_form/form" => "auto_issues#form"
if Rails::VERSION::MAJOR < 4
  put  "auto_issues_form/form" => "auto_issues#form"
else
  patch  "auto_issues_form/form" => "auto_issues#form"
end
