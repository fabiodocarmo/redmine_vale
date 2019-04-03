# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :form_to_xml_jobs, controller: :exec_jobs, type: 'FormToXmlJob'
resources :xml_to_email_jobs, controller: :exec_jobs, type: 'XmlToEmailJob'
