module ExportToValeSapRobot
  module Services
    class ImportNfs

      @logger = Logger.new(Rails.root.join("log", "reports.log"), 15, 100.megabytes)

      def self.update_issues_by_log(params, log_type, issue_id_col, current_status_id, new_status_id, journal_msg_col, custom_field_cols)
        if params[:file].blank?
          return {flash: {error: I18n.t(:no_file_to_import_error_message)}}
        end

        @attachment = Attachment.new(:file => params[:file].tempfile)
        @attachment.author = User.current
        @attachment.filename = Redmine::Utils.random_hex(16)
        @attachment.content_type = params[:file].content_type
        @attachment.save!

        ImportNfseJob.perform_later(@attachment.diskfile, User.current.id, params[:project_id],
          log_type, issue_id_col, current_status_id, new_status_id, journal_msg_col, custom_field_cols)

        return {flash: {notice: I18n.t(:email_will_be_send_when_finish)}}
      end

      def self.categoria_nf_column_possible_values
        {
            Setting.plugin_export_to_vale_sap_robot['nfse_rf_tracker'].to_i => {
                '0' => 'WE', '1' => 'WS'
            },
            Setting.plugin_export_to_vale_sap_robot['recibo_fatura_nd_tracker'].to_i => {
                '1' => 'WQ', '2' => 'WQ', '3' => 'ZM'
            },
            Setting.plugin_export_to_vale_sap_robot['nfse_sps_tracker'].to_i => {
                '0' => 'WE', '1' => 'WS'
            },
            Setting.plugin_export_to_vale_sap_robot['recibo_fatura_nd_sps_tracker'].to_i => {
                '1' => 'WQ', '2' => 'WQ', '3' => 'ZM'
            },
            Setting.plugin_export_to_vale_sap_robot['cte_os_tracker_id'].to_i => {
                '0' => 'CZ'
            },
            Setting.plugin_export_to_vale_sap_robot['danfe_frs_tracker_id'].to_i => {
                '0' => 'I1'
            },
            Setting.plugin_export_to_vale_sap_robot['danfe_sps_tracker_id'].to_i => {
                '0' => 'I1'
            },
            Setting.plugin_export_to_vale_sap_robot['nfse_sedex_rf_tracker'].to_i => {
                'Sedex' => 'H1', 'Avulsa' => 'Z0'
            },
            Setting.plugin_export_to_vale_sap_robot['nfse_sedex_sps_tracker'].to_i => {
                'Sedex' => 'H1', 'Avulsa' => 'Z0'
            },

            Setting.plugin_export_to_vale_sap_robot['rents_tracker_id'].to_i => {
                'Fatura' => 'WQ', 'Recibo' => 'WQ', 'Boleto' => 'WQ', 'Nota de Débito' => 'ZM'
            },
            Setting.plugin_export_to_vale_sap_robot['telecom_tracker_id'].to_i => {
                'Fatura' => 'WQ', 'Nota Fiscal de Telecomunicações' => 'T1'
            },
            Setting.plugin_export_to_vale_sap_robot['utilities_tracker_id'].to_i => {
                'Fatura' => 'WQ', 'Nota Fiscal de Energia Elétrica' => 'ZQ'
            },
            Setting.plugin_export_to_vale_sap_robot['invoice_tracker_id'].to_i => {
                'Fatura' => 'WQ', 'Recibo' => 'WQ', 'Nota de Débito' => 'ZM'
            },
            Setting.plugin_export_to_vale_sap_robot['rpa_tracker_id'].to_i => {
                'RPA' => 'WS'
            },
            Setting.plugin_export_to_vale_sap_robot['priorities_tracker_id'].to_i => {
                'Fatura' => 'WQ', 'Recibo' => 'WQ', 'Boleto' => 'WQ', 'Nota de Débito' => 'ZM'
            },
            Setting.plugin_export_to_vale_sap_robot['dine_tracker_id'].to_i => {
                'Fatura' => 'WQ', 'Recibo' => 'WQ', 'Boleto' => 'WQ'
            },
            Setting.plugin_export_to_vale_sap_robot['danfe_tracker_id'].to_i => {
                'Danfe' => 'I1'
            }
        }
      end

      def self.tipo_filtro_column_possible_values
        {
            Setting.plugin_export_to_vale_sap_robot['nfse_rf_tracker'].to_i => 'Relatório de Agrupamento',
            Setting.plugin_export_to_vale_sap_robot['recibo_fatura_nd_tracker'].to_i => 'Relatório de Agrupamento',
            Setting.plugin_export_to_vale_sap_robot['nfse_sps_tracker'].to_i => 'Pedido/programa de remessas',
            Setting.plugin_export_to_vale_sap_robot['recibo_fatura_nd_sps_tracker'].to_i => 'Pedido/programa de remessas',
            Setting.plugin_export_to_vale_sap_robot['cte_os_tracker_id'].to_i => 'Pedido/programa de remessas',
            Setting.plugin_export_to_vale_sap_robot['danfe_frs_tracker_id'].to_i => 'Relatório de Agrupamento',
            Setting.plugin_export_to_vale_sap_robot['danfe_sps_tracker_id'].to_i => 'Pedido/programa de remessas',
            Setting.plugin_export_to_vale_sap_robot['nfse_sedex_rf_tracker'].to_i => 'Relatório de Agrupamento',
            Setting.plugin_export_to_vale_sap_robot['nfse_sedex_sps_tracker'].to_i => 'Pedido/programa de remessas'
        }
      end


      def self.export_transmission_companies_template(data, fields)
        package  = Axlsx::Package.new
        workbook = package.workbook

        workbook.add_worksheet(name: 'TEMPLATE') do |sheet|
          title = sheet.styles.add_style(bg_color: 'FF007E7A', fg_color: 'FFFFFFFF', sz: 12,  b: true, border: {style: :thin, color: 'FF000000'})

          sheet.add_row (fields), style: title

          data.map { |resource|
            resource.Categoria = categoria_nf_column_possible_values[resource.Tracker][resource["Tipo de Documento"]]
            resource.send('Valor Total NF-e=', ('\'%.2f' % resource.send('Valor Total NF-e').to_f).gsub('.', ','))
            fields.map {
                |field| resource.send(field)
            }
          }.each do |row|
            sheet.add_row row, types: row.map{ |_| :string }
          end
        end

        filename = "tmp/template_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xlsx"
        package.serialize(filename)
        filename
      end

      def self.import_transmission_companies_log(file_path, id_col, log_col, message_col)
        spreadsheet = open_xlsx_file(file_path)
        (2..spreadsheet.last_row).each do |i|

          row = spreadsheet.row(i)

          id  = row[id_col]
          log = row[log_col].to_s.downcase

          match_miro = row[message_col].to_s.match(/(\d{10})/)
          miro = match_miro ? match_miro[1] : nil

          resource = Issue.find_by_id(id)
          next unless resource

          resource.init_journal(User.current, row[message_col])

          resource.custom_field_values = { Setting.plugin_export_to_vale_sap_robot['nfse_miro'] => miro } if log == "ok"
          resource.status_id = log == "ok" ? Setting.plugin_export_to_vale_sap_robot['dine_success_robot_status_id'] : Setting.plugin_export_to_vale_sap_robot['dine_error_robot_status_id']

          resource.current_journal.private_notes = true
          resource.save(validate: false)
        end

        {}
      end

      def self.export_utilities_invoice_template(data, fields)
         self.export_utilities_template(data, fields)
      end

      def self.export_utilities_priorities_template(data, fields)
         self.export_utilities_template(data, fields)
      end

      def self.export_utilities_rpa_template(data, fields)
         self.export_utilities_template(data, fields)
      end

      def self.export_utilities_telecom_template(data, fields)
         self.export_utilities_template(data, fields)
      end

      def self.export_utilities_rents_template(data, fields)
         self.export_utilities_template(data, fields)
      end

      def self.export_utilities_template(data, fields)
        package  = Axlsx::Package.new
        workbook = package.workbook

        workbook.add_worksheet(name: 'TEMPLATE') do |sheet|
          title = sheet.styles.add_style(bg_color: 'FF007E7A', fg_color: 'FFFFFFFF', sz: 12,  b: true, border: {style: :thin, color: 'FF000000'})

          sheet.add_row (fields), style: title

          data.map { |resource|
            resource.Categoria = categoria_nf_column_possible_values[resource.Tracker][resource["Tipo de Documento"]]
            resource.send('Valor Total NF-e=', ('\'%.2f' % resource.send('Valor Total NF-e').to_f).gsub('.', ','))
            fields.map {
                |field| resource.send(field)
            }
          }.each do |row|
            sheet.add_row row, types: row.map{ |_| :string }
          end
        end

        filename = "tmp/template_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xlsx"
        package.serialize(filename)
        filename
      end

      def self.import_invoice_log(file_path, id_col, log_col, message_col)
        spreadsheet = Roo::Spreadsheet.open(file_path, extension: :xlsx)
        (2..spreadsheet.last_row).each do |i|

          row = spreadsheet.row(i)

          id  = row[id_col]
          log = row[log_col].to_s.downcase

          resource = Issue.find_by_id(id)
          next unless resource

          if log == 'ok'
            new_status = Setting.plugin_export_to_vale_sap_robot['invoice_success_robot_status_id']
            match_miro = row[message_col].to_s.match(/(\d{10})/)
            miro = match_miro ? match_miro[1] : nil
            message = ''
          else
            new_status = Setting.plugin_export_to_vale_sap_robot['invoice_error_robot_status_id']
            message = row[message_col]
          end

          resource.init_journal(User.current, message)

          resource.custom_field_values = { Setting.plugin_export_to_vale_sap_robot['nfse_miro'] => miro } if log == "ok"
          resource.status_id = new_status

          resource.current_journal.private_notes = true
          resource.save(validate: false)
        end

        {}
      end

      def self.import_utilities_log(file_path, id_col, log_col, message_col)
        spreadsheet = Roo::Spreadsheet.open(file_path, extension: :xlsx)
        (2..spreadsheet.last_row).each do |i|

          row = spreadsheet.row(i)

          id  = row[id_col]
          log = row[log_col].to_s.downcase

          resource = Issue.find_by_id(id)
          next unless resource

          if log == 'ok'
            new_status = Setting.plugin_export_to_vale_sap_robot['utilities_success_robot_status_id']
            match_miro = row[message_col].to_s.match(/(\d{10})/)
            miro = match_miro ? match_miro[1] : nil
            message = ''
          else
            new_status = Setting.plugin_export_to_vale_sap_robot['utilities_error_robot_status_id']
            message = row[message_col]
          end

          resource.init_journal(User.current, message)

          resource.custom_field_values = { Setting.plugin_export_to_vale_sap_robot['nfse_miro'] => miro } if log == "ok"
          resource.status_id = new_status

          resource.current_journal.private_notes = true
          resource.save(validate: false)
        end

        {}
      end

      def self.import_priorities_log(file_path, id_col, log_col, message_col)
        spreadsheet = Roo::Spreadsheet.open(file_path, extension: :xlsx)

        (2..spreadsheet.last_row).each do |i|

          row = spreadsheet.row(i)

          id  = row[id_col]
          log = row[log_col].to_s.downcase

          resource = Issue.find_by_id(id)
          next unless resource

          if log == 'ok'
            new_status = Setting.plugin_export_to_vale_sap_robot['priorities_success_robot_status_id']
            match_miro = row[message_col].to_s.match(/(\d{10})/)
            miro = match_miro ? match_miro[1] : nil
            message = ''
          else
            new_status = Setting.plugin_export_to_vale_sap_robot['priorities_error_robot_status_id']
            message = row[message_col]
          end

          resource.init_journal(User.current, message)

          resource.custom_field_values = { Setting.plugin_export_to_vale_sap_robot['nfse_miro'] => miro } if log == "ok"
          resource.status_id = new_status

          resource.current_journal.private_notes = true
          resource.save(validate: false)
        end

        {}
      end

      def self.import_rents_log(file_path, id_col, log_col, message_col)
        spreadsheet = Roo::Spreadsheet.open(file_path, extension: :xlsx)

        (2..spreadsheet.last_row).each do |i|

          row = spreadsheet.row(i)

          id  = row[id_col]
          log = row[log_col].to_s.downcase

          resource = Issue.find_by_id(id)
          next unless resource

          if log == 'ok'
            new_status = Setting.plugin_export_to_vale_sap_robot['rents_success_robot_status_id']
            match_miro = row[message_col].to_s.match(/(\d{10})/)
            miro = match_miro ? match_miro[1] : nil
            message = ''
          else
            new_status = Setting.plugin_export_to_vale_sap_robot['rents_error_robot_status_id']
            message = row[message_col]
          end

          resource.init_journal(User.current, message)

          resource.custom_field_values = { Setting.plugin_export_to_vale_sap_robot['nfse_miro'] => miro } if log == "ok"
          resource.status_id = new_status

          resource.current_journal.private_notes = true
          resource.save(validate: false)
        end

        {}
      end

      def self.import_rpa_log(file_path, id_col, log_col, message_col)
        spreadsheet = Roo::Spreadsheet.open(file_path, extension: :xlsx)

        (2..spreadsheet.last_row).each do |i|

          row = spreadsheet.row(i)

          id  = row[id_col]
          log = row[log_col].to_s.downcase

          resource = Issue.find_by_id(id)
          next unless resource

          if log == 'ok'
            new_status = Setting.plugin_export_to_vale_sap_robot['rpa_success_robot_status_id']
            match_miro = row[message_col].to_s.match(/(\d{10})/)
            miro = match_miro ? match_miro[1] : nil
            message = ''
          else
            new_status = Setting.plugin_export_to_vale_sap_robot['rpa_error_robot_status_id']
            message = row[message_col]
          end

          resource.init_journal(User.current, message)

          resource.custom_field_values = { Setting.plugin_export_to_vale_sap_robot['nfse_miro'] => miro } if log == "ok"
          resource.status_id = new_status

          resource.current_journal.private_notes = true
          resource.save(validate: false)
        end

        {}
      end

      def self.import_measurement_log(file_path, id_col,log_col, message_col, requisition_col, requisition_date_col)
        spreadsheet = Roo::Spreadsheet.open(file_path, extension: :xlsx)

        (2..spreadsheet.last_row).each do |i|

          row = spreadsheet.row(i)

          id  = row[id_col]
          log = row[log_col].to_s.downcase

          resource = Issue.find_by_id(id)
          next unless resource

          if log == 'ok'
            new_status = Setting.plugin_export_to_vale_sap_robot['measurement_success_robot_status_id']
            requisition = row[requisition_col].round.to_s
            requisition_date = row[requisition_date_col]
            message = ''
          else
            new_status = Setting.plugin_export_to_vale_sap_robot['measurement_error_robot_status_id']
            message = row[message_col]
          end

          next unless resource.status_id = Setting.plugin_export_to_vale_sap_robot['measurement_robot_status_id'].to_i

          resource.init_journal(User.find(12379), message) #SYSTEM USER

          resource.custom_field_values = { Setting.plugin_export_to_vale_sap_robot['measurement_requisicao'] => requisition, Setting.plugin_export_to_vale_sap_robot['measurement_data_requisicao_id'] => requisition_date } if log == "ok"
          resource.status_id = new_status

          #resource.current_journal.private_notes = true
          resource.save(validate: false)
        end
      end

      def self.import_measurement2_log(file_path, id_col, pedido_col, frs_col, frs_date_col, frs_value_col, log_col)
        spreadsheet = Roo::Spreadsheet.open(file_path, extension: :xlsx)
        last_id = 0
        j = 0
        hash = {}
        same_id = false
        (2..spreadsheet.last_row).each do |i|

          row = spreadsheet.row(i)
          next_row = spreadsheet.row(i+1)

          id  = row[id_col]
          next_id = next_row[id_col]
          j = 0 unless same_id
          same_id = id == next_id
          hash.clear if j == 0
          log = row[log_col].to_s.downcase

          resource = Issue.find_by_id(id)
          next unless resource

          if log == 'ok'
            new_status = Setting.plugin_export_to_vale_sap_robot['measurement2_success_robot_status_id']
            pedido = row[pedido_col].round.to_s
            frs_date = row[frs_date_col]
            frs = row[frs_col].round.to_s
            frs_value = row[frs_value_col].to_s
            temp_hash = { Setting.plugin_export_to_vale_sap_robot["measurement2_pedido_id"].to_i => pedido, Setting.plugin_export_to_vale_sap_robot["measurement2_numero_frs_id"].to_s => frs, Setting.plugin_export_to_vale_sap_robot["measurement2_valor_frs_id"].to_s => frs_value, Setting.plugin_export_to_vale_sap_robot["measurement2_data_frs_id"].to_s => frs_date }
            hash[j] = temp_hash
            j = j + 1
            message = ''
          else
            new_status = Setting.plugin_export_to_vale_sap_robot['measurement2_error_robot_status_id']
            message = row[frs_col].to_s
          end

          next if same_id

          next unless resource.status_id = Setting.plugin_export_to_vale_sap_robot['measurement2_robot_status_id'].to_i

          resource.init_journal(User.find(12379), message) #SYSTEM USER

          resource.custom_field_values = { Setting.plugin_export_to_vale_sap_robot['measurement2_dados_pedido_frs_id'] => hash.to_json } if log == "ok"
          resource.status_id = new_status

          #resource.current_journal.private_notes = true
          resource.save(validate: false)
        end
      end

      def self.export_danfe_nfse_template(nf_data, nf_fields, tax_fields)
        package  = Axlsx::Package.new
        workbook = package.workbook

        workbook.add_worksheet(name: 'Dados') do |sheet|
          title = sheet.styles.add_style(bg_color: 'FF007E7A', fg_color: 'FFFFFFFF', sz: 12,  b: true, border: {style: :thin, color: 'FF000000'})

          sheet.add_row (nf_fields), style: title

          de_para_nomes_municipio = CustomFieldEnumeration.where(custom_field_id: Setting.plugin_export_to_vale_sap_robot['nfse_codigo_municipio_vs_nome'])

          nf_data.each do |resource|
            if resource.grid_linhas_pedido
              resource.NUMERO_LINHAS = JSON.parse(resource.grid_linhas_pedido.gsub('=>',':'))
                                           .map { |k,v| v[Setting.plugin_export_to_vale_sap_robot['danfe_nfse_campos_linhas_pedido']] }
                                           .join(';')
            end

            resource.TIPO_FILTRO = tipo_filtro_column_possible_values[resource.tracker_id]
            resource.CATEGORIA_NF = categoria_nf_column_possible_values[resource.tracker_id][resource.tipo_documento]
            resource.MONTANTE = ( '%.2f' % resource.MONTANTE.to_f).gsub('.', ',')
            resource.SERIE = "-" + resource.SERIE
            resource.REGIAO = resource.chave_acesso[0..1]
            resource.EXERC_CONTABIL = resource.chave_acesso[2..3]
            resource.MES_DOCUMENTO = resource.chave_acesso[4..5]
            resource.NUM_CNPJ = resource.chave_acesso[6..19]
            resource.MODELO_NF = resource.chave_acesso[20..21]
            resource.SERIE_CTE = resource.chave_acesso[22..24]
            resource.NUMERO_NF = resource.chave_acesso[25..33]
            resource.TP_EMISSAO = resource.chave_acesso[34]
            resource.NUM_ALEATORIO = resource.chave_acesso[35..42]
            resource.DIG_VERIF = resource.chave_acesso[43]
          end.map do |resource|
            nf_fields.map { |field| resource.send(field) }
          end.each do |row|
            sheet.add_row row, types: row.map{ |_| :string }
          end
        end

        workbook.add_worksheet(name: 'Impostos') do |sheet|
          title = sheet.styles.add_style(bg_color: 'FF007E7A', fg_color: 'FFFFFFFF', sz: 12,  b: true, border: {style: :thin, color: 'FF000000'})

          sheet.add_row (tax_fields), style: title

          nf_data.each do |resource|
            add_tax_row(sheet, resource.id, 'ISS Retido na Fonte', resource.base_calculo_iss.to_f,
                        resource.aliquota_iss.to_f, resource.valor_documento.to_f, resource.optante_simples == '1')
            add_tax_row(sheet, resource.id, 'INSS Retido na Fonte', resource.base_calculo_inss.to_f,
                        resource.aliquota_inss.to_f, resource.valor_documento.to_f)
          end
        end

        filename = "tmp/template_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xlsx"
        package.serialize(filename)
        filename
      end

      def self.export_cte_os_template(nf_data, nf_fields, tax_fields)
        package  = Axlsx::Package.new
        workbook = package.workbook

        workbook.add_worksheet(name: 'Dados') do |sheet|
          title = sheet.styles.add_style(bg_color: 'FF007E7A', fg_color: 'FFFFFFFF', sz: 12,  b: true, border: {style: :thin, color: 'FF000000'})

          sheet.add_row (nf_fields), style: title

          de_para_nomes_municipio = CustomFieldEnumeration.where(custom_field_id: Setting.plugin_export_to_vale_sap_robot['nfse_codigo_municipio_vs_nome'])

          nf_data.each do |resource|
            if resource.grid_linhas_pedido
              resource.NUMERO_LINHAS = JSON.parse(resource.grid_linhas_pedido.gsub('=>',':'))
                                           .map { |k,v| v[Setting.plugin_export_to_vale_sap_robot['cte_os_campos_linhas_pedido']] }
                                           .join(';')
            end

            resource.TIPO_FILTRO = tipo_filtro_column_possible_values[resource.tracker_id]
            resource.CATEGORIA_NF = categoria_nf_column_possible_values[resource.tracker_id][resource.tipo_documento]
            resource.MONTANTE = ( '%.2f' % resource.MONTANTE.to_f).gsub('.', ',')
            resource.SERIE = "-" + resource.SERIE
            resource.REGIAO = resource.chave_acesso[0..1]
            resource.EXERC_CONTABIL = resource.chave_acesso[2..3]
            resource.MES_DOCUMENTO = resource.chave_acesso[4..5]
            resource.NUM_CNPJ = resource.chave_acesso[6..19]
            resource.MODELO_NF = resource.chave_acesso[20..21]
            resource.SERIE_CTE = resource.chave_acesso[22..24]
            resource.NUMERO_NF = resource.chave_acesso[25..33]
            resource.TP_EMISSAO = resource.chave_acesso[34]
            resource.NUM_ALEATORIO = resource.chave_acesso[35..42]
            resource.DIG_VERIF = resource.chave_acesso[43]
          end.map do |resource|
            nf_fields.map { |field| resource.send(field) }
          end.each do |row|
            sheet.add_row row, types: row.map{ |_| :string }
          end
        end

        workbook.add_worksheet(name: 'Impostos') do |sheet|
          title = sheet.styles.add_style(bg_color: 'FF007E7A', fg_color: 'FFFFFFFF', sz: 12,  b: true, border: {style: :thin, color: 'FF000000'})

          sheet.add_row (tax_fields), style: title

          nf_data.each do |resource|
            add_tax_row(sheet, resource.id, 'INSS Retido na Fonte', resource.base_calculo_inss.to_f,
                        resource.aliquota_inss.to_f, resource.valor_documento.to_f)
          end
        end

        filename = "tmp/template_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xlsx"
        package.serialize(filename)
        filename
      end

      def self.export_nfse_template(nf_data, nf_fields, tax_fields)
        package  = Axlsx::Package.new
        workbook = package.workbook

        workbook.add_worksheet(name: 'Dados') do |sheet|
          title = sheet.styles.add_style(bg_color: 'FF007E7A', fg_color: 'FFFFFFFF', sz: 12,  b: true, border: {style: :thin, color: 'FF000000'})

          sheet.add_row (nf_fields), style: title

          de_para_nomes_municipio = CustomFieldEnumeration.where(custom_field_id: Setting.plugin_export_to_vale_sap_robot['nfse_codigo_municipio_vs_nome'])

          nf_data.each do |resource|
            if resource.grid_linhas_pedido
              resource.NUMERO_LINHAS = JSON.parse(resource.grid_linhas_pedido.gsub('=>',':'))
                                           .map { |k,v| v[Setting.plugin_export_to_vale_sap_robot['sps_campos_linhas_pedido']] }
                                           .join(';')
            end
            resource.TIPO_FILTRO = tipo_filtro_column_possible_values[resource.tracker_id]
            resource.CATEGORIA_NF = categoria_nf_column_possible_values[resource.tracker_id][resource.tipo_documento]
            resource.MUNICIPIO = de_para_nomes_municipio.detect { |x| x.key == resource.MUNICIPIO }.try(:name)
            resource.MONTANTE = ( '%.2f' % resource.MONTANTE.to_f).gsub('.', ',')
          end.map do |resource|
            nf_fields.map { |field| resource.send(field) }
          end.each do |row|
            sheet.add_row row, types: row.map{ |_| :string }
          end
        end

        workbook.add_worksheet(name: 'Impostos') do |sheet|
          title = sheet.styles.add_style(bg_color: 'FF007E7A', fg_color: 'FFFFFFFF', sz: 12,  b: true, border: {style: :thin, color: 'FF000000'})
          sheet.add_row (tax_fields), style: title

          nf_data.each do |resource|
            add_tax_row(sheet, resource['ID'], 'ISS Retido na Fonte', resource.base_calculo_iss.to_f,
                        resource.aliquota_iss.to_f, resource.valor_documento.to_f, resource.optante_simples == '1')
            add_tax_row(sheet, resource['ID'], 'INSS Retido na Fonte', resource.base_calculo_inss.to_f,
                        resource.aliquota_inss.to_f, resource.valor_documento.to_f)
          end

        end

        filename = "tmp/template_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xlsx"
        package.serialize(filename)
        filename
      end

      def self.add_tax_row(sheet, id, description, base_calculo, aliquota, montante, optante_simples = false)
        if Setting.plugin_export_to_vale_sap_robot['nfse_tax_decimal_precision'].blank?
          precision = 20
        else
          precision = Setting.plugin_export_to_vale_sap_robot['nfse_tax_decimal_precision'].to_i
        end

        if ((base_calculo > 0) && (base_calculo < montante)) || optante_simples
          row = [id,
                 description,
                 ("%.#{precision}f" % (100.0 * (base_calculo / montante).round(precision))).gsub('.', ','),
                 ('%.2f' % aliquota).gsub('.', ','),
                 'true',
                 ''
          ]
          sheet.add_row row, types: row.map { |_| :string }
        end
      end

      def self.import_nfse_log(file_path, user_id, project_identifier, log_type, issue_id_col,
          current_status_id, new_status_id, journal_msg_col, custom_field_cols)
        spreadsheet = CSV.read(file_path, encoding: 'ISO-8859-1', col_sep: '|', quote_char: '✓')

        (1..(spreadsheet.count-1)).each do |i|
          row = spreadsheet[i]
          id  = row[issue_id_col]
          resource = Issue.find_by_id(id)
          user = User.find(user_id)

          next unless resource && user &&
            resource.project.identifier == project_identifier &&
            resource.status_id == current_status_id.to_i

          resource.init_journal(user)
          if journal_msg_col
              resource.current_journal.notes = row[journal_msg_col]
            resource.current_journal.private_notes = true
          end

          resource.status_id = new_status_id

          if custom_field_cols
            custom_field_cols.each do |cf|
              next unless cf[:id]
              value = row[cf[:col]]
              resource.custom_field_values = { cf[:id] => value }
            end
          end

          resource.save(validate: false)
        end

        {}
      end

      def self.import_no_nfse_log(file_path, user_id, project_identifier)
        spreadsheet = open_xlsx_file(file_path)
        user = User.find(user_id)
        project = Project.where(identifier: project_identifier).first
        rf_col = 3
        current_status_id = Setting.plugin_export_to_vale_sap_robot['grc_waiting_status_id'].to_i
        grc_error_status_id = Setting.plugin_export_to_vale_sap_robot['grc_error_status_id'].to_i
        cf_rf = Setting.plugin_export_to_vale_sap_robot['nfse_numero_rf'].to_i

        (2..spreadsheet.last_row).each do |i|
          row = spreadsheet.row(i)
          rf  = row[rf_col]
          begin
            rf = rf.to_i
          rescue
            next
          end

          next unless rf > 0

          issue = Issue.joins(:custom_values)
            .where(project_id: project.id)
            .where(status_id: current_status_id)
            .where(custom_values:{custom_field_id:cf_rf})
            .where("custom_values.value ~ '[0]*?'", rf).first

          next unless issue

          issue.status_id = grc_error_status_id
          issue.init_journal(user)
          issue.save(validate: false)
        end

      end

      def self.import_grc_report(file_path, user_id, project_identifier)
        spreadsheet = open_xlsx_file(file_path)
        user = User.find(user_id)
        project = Project.where(identifier: project_identifier).first
        rf_col = 3
        nf_col = 7
        status_col = 2
        miro_col = 43
        finished_status_value = "Concluído"
        error_status_value = "Erro"
        cancelled_status_value = "Cancelado"
        waiting_miro_status_value = "Aguardando Aprovação da MIRO"
        waiting_nf_status_value = "Aguardando NFS-e"
        waiting_process = "Aguardando Processamento"
        rf_cancel_error = "Falha ao Cancelar RF"
        current_status_id = Setting.plugin_export_to_vale_sap_robot['grc_waiting_status_id'].to_i
        robot_status_id = Setting.plugin_export_to_vale_sap_robot['grc_robot_status_id'].to_i
        finish_status_id = Setting.plugin_export_to_vale_sap_robot['grc_success_robot_status_id'].to_i
        grc_error_status_id = Setting.plugin_export_to_vale_sap_robot['grc_error_status_id'].to_i
        cf_rf = Setting.plugin_export_to_vale_sap_robot['nfse_numero_rf'].to_i
        cf_nf = Setting.plugin_export_to_vale_sap_robot['nfse_referencia'].to_i
        cf_miro = Setting.plugin_export_to_vale_sap_robot['nfse_miro'].to_i
        issue_ids = []
        not_in_grc_issue_ids = []

        (2..spreadsheet.last_row).each do |i|

          if project_identifier == 'cadastro-via-grc-de-nf-transporte'

            row = spreadsheet.row(i)

            cod_verif_col = 6
            data_emissao_col = 11
            cnpj_col = 15
            n_doc_col = 7

            cod_verif = row[cod_verif_col]

            next unless cod_verif == 'FRETE'

            data_emissao = row[data_emissao_col]
            cnpj = row[cnpj_col]

            begin
              n_doc = row[n_doc_col].to_i
            rescue
              next
            end

            issue = Issue.joins(:custom_values)
                .joins("join custom_values cnpj
                          on cnpj.customized_id = issues.id
                          and cnpj.customized_type = 'Issue'
                          and cnpj.custom_field_id = 1
                        join custom_values data_emissao
                          on data_emissao.customized_id = issues.id
                          and data_emissao.customized_type = 'Issue'
                          and data_emissao.custom_field_id = 11
                        join custom_values n_doc
                          on n_doc.customized_id = issues.id
                          and n_doc.customized_type = 'Issue'
                          and n_doc.custom_field_id = 1083")
                .where(project_id: project.id)
                .where(status_id: current_status_id)
                .where("cnpj.value_hashed = ?", Digest::SHA256.hexdigest(cnpj))
                .where("data_emissao.value_hashed = ?", Digest::SHA256.hexdigest(data_emissao.to_s))
                .where("n_doc.value ~ '[0]*?'", n_doc)
                .first

            next unless issue

            grc_status = row[status_col]
            case grc_status
            when finished_status_value #Concluído
              new_status_id = finish_status_id
              miro = row[miro_col]
              if miro
                issue.init_journal(user)
                issue.custom_field_values = { cf_miro => miro }
              end
            when error_status_value, cancelled_status_value, rf_cancel_error
              new_status_id = grc_error_status_id
            when waiting_miro_status_value
              issue_ids << issue.id
              new_status_id = robot_status_id
              miro = row[miro_col]
              if miro
                issue.init_journal(user)
                issue.custom_field_values = { cf_miro => miro }
              end
            when waiting_nf_status_value, waiting_process
              not_in_grc_issue_ids << issue.id
              next
            else
              next
            end

          else

            row = spreadsheet.row(i)
            rf  = row[rf_col]
            nf  = row[nf_col]

            begin
              nf = nf.to_i
              rf = rf.to_i
            rescue
              next
            end

            next unless rf > 0


            grc_status = row[status_col]
            case grc_status
            when finished_status_value
              issue = Issue.joins(:custom_values)
                .joins("INNER JOIN custom_values c on c.customized_id = issues.id AND c.customized_type = 'Issue'")
                .where(project_id: project.id)
                .where(status_id: current_status_id)
                .where(custom_values:{custom_field_id:cf_nf})
                .where("custom_values.value ~ '[0]*?'", nf)
                .where(c:{custom_field_id:cf_rf})
                .where("c.value ~ '[0]*?'", rf).first
              next unless issue
              new_status_id = finish_status_id
              miro = row[miro_col]
              if miro
                issue.init_journal(user)
                issue.custom_field_values = { cf_miro => miro }
              end
            when error_status_value, cancelled_status_value, rf_cancel_error
              issue = Issue.joins(:custom_values)
              .where(project_id: project.id)
              .where(status_id: current_status_id)
              .where(custom_values:{custom_field_id:cf_rf})
              .where("custom_values.value ~ '[0]*?'", rf).first
              next unless issue
              new_status_id = grc_error_status_id
            when waiting_miro_status_value
              issue = Issue.joins(:custom_values)
                .joins("INNER JOIN custom_values c on c.customized_id = issues.id AND c.customized_type = 'Issue'")
                .where(project_id: project.id)
                .where(status_id: current_status_id)
                .where(custom_values:{custom_field_id:cf_nf})
                .where("custom_values.value ~ '[0]*?'", nf)
                .where(c:{custom_field_id:cf_rf})
                .where("c.value ~ '[0]*?'", rf).first
              next unless issue
              issue_ids << issue.id
              new_status_id = robot_status_id
              miro = row[miro_col]
              if miro
                issue.init_journal(user)
                issue.custom_field_values = { cf_miro => miro }
              end
            when waiting_nf_status_value, waiting_process
              issue = Issue.joins(:custom_values)
                .where(project_id: project.id)
                .where(status_id: current_status_id)
                .where(custom_values:{custom_field_id:cf_rf})
                .where("custom_values.value ~ '[0]*?'", rf).first
              next unless issue
              not_in_grc_issue_ids << issue.id
              next
            else
              next
            end
          end

          issue.init_journal(user)
          issue.status_id = new_status_id
          issue.save(validate: false)
        end

        export_to_grc_robot(issue_ids, not_in_grc_issue_ids, user)
      end

      def self.export_to_grc_robot(issue_ids, not_in_grc_issue_ids, user)
        package  = Axlsx::Package.new
        workbook = package.workbook

        workbook.add_worksheet(name: 'Principal') do |sheet|
          title = sheet.styles.add_style(bg_color: 'FF007E7A', fg_color: 'FFFFFFFF', sz: 12,  b: true, border: {style: :thin, color: 'FF000000'})
          data = [ { id: "NUMERO_RF", header: "RF"},
            {id: "NF", header: "Nota Fiscal"},
            {id: "MIRO", header: "MIRO"},
            {id: "Valor_NF", header: "Valor da NF"},
            {id: "CHAMADO", header: "CHAMADO"},
            {id: "CNPJ_FORNECEDOR", header: "CNPJ Fornecedor"},
            {id: "Emissao", header: "Emissão"},
            {id: "Recebimento", header: "Recebimento"},
            {id: "BASE_ISS", header: "BASE ISS"},
            {id: "ALIQUOTA_ISS", header: "ALIQUOTA ISS"},
            {id: "BASE_INSS", header: "BASE INSS"},
            {id: "CEI", header: "CEI"},
            {id: "SIMPLES_NACIONAL", header: "SIMPLES NACIONAL"}]

          issues = Issue.where(id: issue_ids)
          .joins("left join custom_values cv_referencia_nfse on cv_referencia_nfse.customized_id = issues.id and cv_referencia_nfse.customized_type = 'Issue' and cv_referencia_nfse.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_referencia']}'")
          .joins("left join custom_values cv_numero_rf on cv_numero_rf.customized_id = issues.id and cv_numero_rf.customized_type = 'Issue' and cv_numero_rf.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_numero_rf']}'")
          .joins("left join custom_values cv_miro on cv_miro.customized_id = issues.id and cv_miro.customized_type = 'Issue' and cv_miro.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_miro']}'")
          .joins("left join custom_values cv_cnpj_fornecedor on cv_cnpj_fornecedor.customized_id = issues.id and cv_cnpj_fornecedor.customized_type = 'Issue' and cv_cnpj_fornecedor.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_cnpj_fornecedor']}'")
          .joins("left join custom_values cv_base_calculo_iss on cv_base_calculo_iss.customized_id = issues.id and cv_base_calculo_iss.customized_type = 'Issue' and cv_base_calculo_iss.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_base_calculo_iss']}'")
          .joins("left join custom_values cv_base_calculo_inss on cv_base_calculo_inss.customized_id = issues.id and cv_base_calculo_inss.customized_type = 'Issue' and cv_base_calculo_inss.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_base_calculo_inss']}'")
          .joins("left join custom_values cv_aliquota_iss on cv_aliquota_iss.customized_id = issues.id and cv_aliquota_iss.customized_type = 'Issue' and cv_aliquota_iss.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_aliquota_iss']}'")
          .joins("left join custom_values cv_aliquota_inss on cv_aliquota_inss.customized_id = issues.id and cv_aliquota_inss.customized_type = 'Issue' and cv_aliquota_inss.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_aliquota_inss']}'")
          .joins("left join custom_values cv_optante_simples on cv_optante_simples.customized_id = issues.id and cv_optante_simples.customized_type = 'Issue' and cv_optante_simples.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_optante_simples']}'")
          .joins("left join custom_values cv_montante on cv_montante.customized_id = issues.id and cv_montante.customized_type = 'Issue' and cv_montante.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_montante']}'")
          .joins("left join custom_values cv_texto on cv_texto.customized_id = issues.id and cv_texto.customized_type = 'Issue' and cv_texto.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_texto']}'")
          .joins("left join custom_values cv_data_fatura on cv_data_fatura.customized_id = issues.id and cv_data_fatura.customized_type = 'Issue' and cv_data_fatura.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_data_fatura']}'")
          .joins("left join custom_values cv_data_basica on cv_data_basica.customized_id = issues.id and cv_data_basica.customized_type = 'Issue' and cv_data_basica.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_data_basica']}'")
          .joins("left join custom_values cv_referencia_recibo_fatura_nd on cv_referencia_recibo_fatura_nd.customized_id = issues.id and cv_referencia_recibo_fatura_nd.customized_type = 'Issue' and cv_referencia_recibo_fatura_nd.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_referencia_recibo_fatura_nd']}'")
          .joins("left join custom_values cv_numero_rf on cv_numero_rf.customized_id = issues.id and cv_numero_rf.customized_type = 'Issue' and cv_numero_rf.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_numero_rf']}'")
          .joins("left join custom_values cv_grid_linhas_pedido on cv_grid_linhas_pedido.customized_id = issues.id and cv_grid_linhas_pedido.customized_type = 'Issue' and cv_grid_linhas_pedido.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['sps_grid_linhas_pedido']}'")
          .joins("left join custom_values cv_tipo_documento_recibo_fatura_nd on cv_tipo_documento_recibo_fatura_nd.customized_id = issues.id and cv_tipo_documento_recibo_fatura_nd.customized_type = 'Issue' and cv_tipo_documento_recibo_fatura_nd.custom_field_id = '#{Setting.plugin_export_to_vale_sap_robot['nfse_tipo_documento_recibo_fatura_nd']}'")
          .select('issues.id')
          .select('cv_numero_rf.value as "NUMERO_RF"')
          .select('cv_montante.value as "Valor_NF"')
          .select('cv_miro.value as "MIRO"')
          .select('issues.id as "CHAMADO"')
          .select('concat(\'\'\'\', cv_cnpj_fornecedor.value) as "CNPJ_FORNECEDOR"')
          .select('to_char(cv_data_fatura.value::date, \'\'\'DD.MM.YYYY\') as "Emissao"')
          .select("to_char(nullif(cv_data_basica.value, '')::date, \'\'\'DD.MM.YYYY\') as \"Recebimento\"")
          .select('cv_base_calculo_iss.value as "BASE_ISS"')
          .select('cv_aliquota_iss.value as "ALIQUOTA_ISS"')
          .select('cv_base_calculo_inss.value as "BASE_INSS"')
          .select('cv_texto.value as "CEI"')
          .select('cv_optante_simples.value as "SIMPLES_NACIONAL"')
          .select('RIGHT(cv_referencia_nfse.value,6) as "NF"')
          .select('issues.tracker_id')
          .select('cv_grid_linhas_pedido.value as "grid_linhas_pedido"')
          .select('coalesce(cv_tipo_documento_recibo_fatura_nd.value, \'0\') as "tipo_documento"')
          .order(:id)

          return nil if issues.blank? && not_in_grc_issue_ids.empty?

          sheet.add_row (data.map{|d| d[:header]}), style: title

          if Setting.plugin_export_to_vale_sap_robot['nfse_tax_decimal_precision'].blank?
            precision = 20
          else
            precision = Setting.plugin_export_to_vale_sap_robot['nfse_tax_decimal_precision'].to_i
          end

          issues.each do |resource|
            if ((resource.BASE_INSS.to_f > 0) && (resource.BASE_INSS.to_f < resource.Valor_NF.to_f)) || resource.SIMPLES_NACIONAL
              resource.BASE_INSS = ("%.#{precision}f" % (100.0 * (resource.BASE_INSS.to_f / resource.Valor_NF.to_f).round(precision))).gsub('.', ',')
            end
            if ((resource.BASE_ISS.to_f > 0) && (resource.BASE_ISS.to_f < resource.Valor_NF.to_f)) || resource.SIMPLES_NACIONAL
              resource.BASE_ISS = ("%.#{precision}f" % (100.0 * (resource.BASE_ISS.to_f / resource.Valor_NF.to_f).round(precision))).gsub('.', ',')
            end
            resource.ALIQUOTA_ISS = ('%.2f' % resource.ALIQUOTA_ISS).gsub('.', ',')
            resource.Valor_NF = ( '%.2f' % resource.Valor_NF.to_f).gsub('.', ',')
            resource.SIMPLES_NACIONAL = (resource.SIMPLES_NACIONAL == "1" ? "Sim" : "Não")
          end.map do |resource|
            data.map { |field| resource[field[:id]] }
          end.each do |row|
            sheet.add_row row, types: row.map{ |_| :string }
          end

        end

        workbook.add_worksheet(name: 'Erro ao cadastrar no GRC') do |sheet|
          title = sheet.styles.add_style(bg_color: 'FF007E7A', fg_color: 'FFFFFFFF', sz: 12,  b: true, border: {style: :thin, color: 'FF000000'})
          sheet.add_row(["CHAMADO"], style: title)
          not_in_grc_issue_ids.each do |id|
            sheet.add_row [id.to_s]
          end
        end

        filename = "tmp/template_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xlsx"
        package.serialize(filename)
        filename
        # ExportReportMailer.notify_external(user, 'Export_robo_grc.xlsx', filename, "Exportação para robô do GRC").deliver
        # send_file(filename, filename: 'export_robo_grc.xlsx', type: "application/vnd.ms-excel")
      end

      def self.export_priorities_template(data, fields)
        package  = Axlsx::Package.new
        workbook = package.workbook

        workbook.add_worksheet(name: 'TEMPLATE') do |sheet|
          title = sheet.styles.add_style(bg_color: 'FF007E7A', fg_color: 'FFFFFFFF', sz: 12,  b: true, border: {style: :thin, color: 'FF000000'})

          sheet.add_row (fields), style: title

          data.map { |resource|
            resource.send('Valor Total NF-e=', ('\'%.2f' % resource.send('Valor Total NF-e').to_f).gsub('.', ','))
            fields.map {
                |field| resource.send(field)
            }
          }.each do |row|
            sheet.add_row row, types: row.map{ |_| :string }
          end
        end

        filename = "tmp/template_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xlsx"
        package.serialize(filename)
        filename
      end

      def self.export_measurement_template(data, fields)
        package  = Axlsx::Package.new
        workbook = package.workbook

        workbook.add_worksheet(name: 'TEMPLATE') do |sheet|
          title = sheet.styles.add_style(bg_color: 'FF007E7A', fg_color: 'FFFFFFFF', sz: 12,  b: true, border: {style: :thin, color: 'FF000000'})

          sheet.add_row (fields), style: title

          data = data.select { |resource| ! /^[sS]/.match(resource.send('Classificação Contábil')) }

          data.map { |resource|
            resource.send('Valor=', ('\'%.2f' % resource.send('Valor').to_f).gsub('.', ','))
            resource.send('Classificação Contábil=', /^[cCaArRgG]/.match(resource.send('Classificação Contábil')) ? 'P' :  resource.send('Classificação Contábil').size == 8 ? 'F' : 'K')
            fields.map {
                |field| resource.send(field)
            }
          }.each do |row|
            sheet.add_row row, types: row.map{ |_| :string }
          end
        end

        filename = "tmp/template_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xlsx"
        package.serialize(filename)
        filename
      end

      def self.export_measurement2_template(data, fields)
        package  = Axlsx::Package.new
        workbook = package.workbook

        workbook.add_worksheet(name: 'TEMPLATE') do |sheet|
          title = sheet.styles.add_style(bg_color: 'FF007E7A', fg_color: 'FFFFFFFF', sz: 12,  b: true, border: {style: :thin, color: 'FF000000'})

          sheet.add_row (fields), style: title

          data.map { |resource|
            fields.map {
                |field| resource.send(field)
            }
          }.each do |row|
            sheet.add_row row, types: row.map{ |_| :string }
          end
        end

        filename = "tmp/template_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xlsx"
        package.serialize(filename)
        filename
      end


      def self.open_xlsx_file(file_path)
        Roo::Spreadsheet.open(file_path, extension: :xlsx)
      end


    end
  end

end
