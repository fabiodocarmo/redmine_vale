Redmine::Plugin.register :export_to_vale_sap_robot do
  name 'Export To Vale Sap Robot plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  settings default: {}, :partial => 'settings/export_to_vale_sap_robot'

  project_module :export_to_vale_sap_robot do
    permission :export_to_vale_nfse_robot,
               { :export_to_vale_nfse_robot => [:index, :create, :update_ok, :update_error] }
    permission :export_to_vale_transmission_companies_robot,
               { :export_to_vale_transmission_companies_robot => [:index, :create, :update] }
    permission :export_to_vale_telecom_companies_robot,
              { :export_to_vale_telecom_companies_robot => [:index, :create, :update] }
    permission :export_to_vale_danfe_companies_robot,
              { :export_to_vale_danfe_companies_robot => [:index, :create, :update] }
    permission :export_to_vale_utilities_invoice_robot,
              {
                  :export_to_vale_invoice_robot => [:index, :create, :update],
                  :export_to_vale_utilities_robot => [:index, :create, :update]
              }
    permission :export_to_vale_cte_os_robot,
             { :export_to_vale_cte_os_robot => [:index, :create, :update_ok, :update_error] }

    permission :export_to_vale_danfe_nfse_robot,
            { :export_to_vale_danfe_nfse_robot => [:index, :create, :update_ok, :update_error] }

    permission :export_to_vale_priorities_robot,
            { :export_to_vale_priorities_robot => [:index, :create, :update, :update_error] }

    permission :export_to_vale_rpa_robot,
            { :export_to_vale_rpa_robot => [:index, :create, :update, :update_error] }

    permission :export_to_vale_rents_robot,
            { :export_to_vale_rents_robot => [:index, :create, :update, :update_error] }

    permission :export_to_vale_measurement_robot,
            { :export_to_vale_measurement_robot => [:index, :create, :update, :update_error] }

    permission :export_to_vale_measurement2_robot,
        { :export_to_vale_measurement2_robot => [:index, :create, :update, :update_error] }         

  end

  project_module :export_to_vale_sap_grc_robot do
    permission :export_to_vale_grc_robot,
               { :export_to_vale_grc_robot => [:index, :import_grc_report, :update_grc_robot_ok, :update_grc_robot_error, :update_send_to_nfse_robot] }
  end

  menu :project_menu, :export_to_vale_invoice_robot,
       {controller: :export_to_vale_invoice_robot, action: :index },
       caption: :export_to_vale_invoice_robot, param: :project_id

  menu :project_menu, :export_to_vale_utilities_robot,
       {controller: :export_to_vale_utilities_robot, action: :index },
       caption: :export_to_vale_utilities_robot, param: :project_id

  menu :project_menu, :export_to_vale_transmission_companies_robot,
       {controller: :export_to_vale_transmission_companies_robot, action: :index },
       caption: :export_to_vale_transmission_companies_robot, param: :project_id

  menu :project_menu, :export_to_vale_telecom_companies_robot,
        {controller: :export_to_vale_telecom_companies_robot, action: :index },
        caption: :export_to_vale_telecom_companies_robot, param: :project_id

  menu :project_menu, :export_to_vale_danfe_companies_robot,
        {controller: :export_to_vale_danfe_companies_robot, action: :index },
        caption: :export_to_vale_danfe_companies_robot, param: :project_id

  menu :project_menu, :export_to_vale_nfse_robot,
       {controller: :export_to_vale_nfse_robot, action: :index },
       caption: :export_to_vale_nfse_robot, param: :project_id

  menu :project_menu, :export_to_vale_grc_robot,
       {controller: :export_to_vale_grc_robot, action: :index },
       caption: :export_to_vale_grc_robot, param: :project_id

  menu :project_menu, :export_to_vale_cte_os_robot,
       {controller: :export_to_vale_cte_os_robot, action: :index },
       caption: :export_to_vale_cte_os_robot, param: :project_id

  menu :project_menu, :export_to_vale_danfe_nfse_robot,
       {controller: :export_to_vale_danfe_nfse_robot, action: :index },
       caption: :export_to_vale_danfe_nfse_robot, param: :project_id

  menu :project_menu, :export_to_vale_priorities_robot,
       {controller: :export_to_vale_priorities_robot, action: :index },
       caption: :export_to_vale_priorities_robot, param: :project_id

  menu :project_menu, :export_to_vale_rpa_robot,
       {controller: :export_to_vale_rpa_robot, action: :index },
       caption: :export_to_vale_rpa_robot, param: :project_id

  menu :project_menu, :export_to_vale_rents_robot,
       {controller: :export_to_vale_rents_robot, action: :index },
       caption: :export_to_vale_rents_robot, param: :project_id

  menu :project_menu, :export_to_vale_measurement_robot,
       {controller: :export_to_vale_measurement_robot, action: :index },
       caption: :export_to_vale_measurement_robot, param: :project_id

  menu :project_menu, :export_to_vale_measurement2_robot,
     {controller: :export_to_vale_measurement2_robot, action: :index },
     caption: :export_to_vale_measurement2_robot, param: :project_id

end
