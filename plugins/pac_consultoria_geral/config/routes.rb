# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html


resources :assign_to_consultor_geral_job, controller: :exec_jobs, type: 'AssignToConsultorGeralJob'
resources :assign_to_gestor_contrato_job, controller: :exec_jobs, type: 'AssignToGestorContratoJob'
resources :assign_to_gerente_job, controller: :exec_jobs, type: 'AssignToGerenteJob'
resources :certified_supplier_job, controller: :exec_jobs, type: 'CertifiedSupplierJob'
resources :set_consultor_geral_job, controller: :exec_jobs, type: 'SetConsultorGeralJob'
resources :set_pac_subject_job, controller: :exec_jobs, type: 'SetPacSubjectJob'
resources :validate_company_distribution_sum_job, controller: :exec_jobs, type: 'ValidateCompanyDistributionSumJob'
resources :validate_vigencia_job, controller: :exec_jobs, type: 'ValidateVigenciaJob'
resources :validate_tipo_pac_job, controller: :exec_jobs, type: 'ValidateTipoPacJob'
resources :validate_metodo_contratacao_job, controller: :exec_jobs, type: 'ValidateTipoPacJob'
