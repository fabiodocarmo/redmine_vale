module ReqToPayProcessing
  
  def self.update_by_req_to_pay(attachment_id)

    attachment = Attachment.find attachment_id
    spreadsheet = Roo::Spreadsheet.open(attachment.diskfile, extension: attachment.description.to_sym)
    
    begin
      first_row = Setting.plugin_bm_xls_to_form["req_to_pay_row"].to_i
      coluna_rf = Setting.plugin_bm_xls_to_form["req_to_pay_rf_column"].to_i
      coluna_ndoc = Setting.plugin_bm_xls_to_form["req_to_pay_ndocref_column"].to_i
      coluna_pedido = Setting.plugin_bm_xls_to_form["req_to_pay_order_column"].to_i
      coluna_frs = Setting.plugin_bm_xls_to_form["req_to_pay_frs_column"].to_i
      coluna_compensacao = Setting.plugin_bm_xls_to_form["req_to_pay_clearing_column"].to_i
      coluna_data_compensacao = Setting.plugin_bm_xls_to_form["req_to_pay_clearing_date_column"].to_i
      
      report_data = []

      (first_row..spreadsheet.last_row).each do |row|

        data_compensacao = spreadsheet.cell(row, coluna_data_compensacao)
        if data_compensacao.blank? ||
           data_compensacao == 0 ||
           (data_compensacao = Date.strptime(data_compensacao, '%d.%m.%Y')) &&
           data_compensacao.year < 2000
          next
        end

        pedido = spreadsheet.cell(row, coluna_pedido) || ''
        frs = spreadsheet.cell(row, coluna_frs) || ''
        rf_list = (spreadsheet.cell(row, coluna_rf) || '').strip.split(/[^\d]+/)
        n_doc_ref = spreadsheet.cell(row, coluna_ndoc) || ''
        num_compensacao = spreadsheet.cell(row, coluna_compensacao) || ''

        if rf_list.present?
          rf_list.each do |rf|
            report_data << [pedido, frs, rf, num_compensacao, data_compensacao, n_doc_ref]
          end
        else
          report_data << [pedido, frs, '', num_compensacao, data_compensacao, n_doc_ref]
        end
      end

      grouped_data = find_and_group_by_issue(report_data.uniq)
      updated_ids = self.update_issues(grouped_data)
    rescue => error
      Rails.logger.error("Erro na importação do relatório ReqToPay - mensagem: #{error.message}\n#{error.backtrace.first}")
    end
    updated_ids
  end

  def self.find_and_group_by_issue(report_data)
    grouped_data = {}
    report_data.each do |data|
      if data[2].present?
        issue = self.find_bm_issue_by_rf(data[2])
      else
        issue = self.find_bm_issue_by_order(data[0])
      end
      if issue.present?
        if issue.id.in? grouped_data
          grouped_data[issue.id] << data
        else
          grouped_data[issue.id] = [data]
        end
      end
    end
    grouped_data
  end

  def self.update_issues(grouped_data)
    updated_ids = []
    grouped_data.each do |issue_id, data|
    begin
      issue = Issue.find(issue_id)
      next unless issue.status_id.to_s.in? valid_statuses
      issue_order_list = issue.custom_field_value(1365).scan(/"1291\"=>\"(\d{10})/).flatten.uniq.sort
      data_order_list = data.map{|m| m[0]}.select{|s| s.present?}.uniq.sort
      data_rf_list = data.map{|m| m[2]}.select{|s| s.present?}.uniq.sort
      if data_rf_list.present?
        issue_rf_list = issue.custom_field_value(1370).scan(/"1296\"=>\"(\d{10})/).flatten.uniq.sort
        next unless data_rf_list == issue_rf_list
      else
        next unless data_order_list == issue_order_list
      end

      str_grid = generate_grid_string(data)

      bm_status = data.map{|m| m[3]}.select{|s| s.blank?}.present? ?
                    Setting.plugin_bm_xls_to_form["status_scheduled_payment"] :
                    Setting.plugin_bm_xls_to_form["status_payment_executed"]

      issue.reload
      journal = issue.init_journal(self.journal_user, 'Atualização via ReqToPay.')
      journal.notify = false
      issue.status_id = bm_status
      issue.custom_field_values = {Setting.plugin_bm_xls_to_form["reqtopay_grid_field"].to_i => str_grid}

      next unless issue.status_id_changed? #or issue.custom_field_values.changed?

      
      if issue.save(validate: false)
        updated_ids << issue.id
        Rails.logger.info("ReqToPay: Issue #{issue.id} salva com sucesso com status_id #{bm_status}.")
      end
      rescue => error
        Rails.logger.error("ReqToPay: Erro ao processar issue #{issue.id} || Erro: #{error.message}")
      end
    end
    updated_ids
  end

  def self.find_bm_issue_by_rf(rf)

    tracker_bm = Setting.plugin_bm_xls_to_form["tracker_id"]
    grid_cf_id = Setting.plugin_bm_xls_to_form["grid_rf_data"]
    rf_column_id = Setting.plugin_bm_xls_to_form["bm_rf_field"]

    Issue.select(:id).joins(ActiveRecord::Base.__send__(:sanitize_sql,
      ["join custom_values
          on issues.id = custom_values.customized_id
          and custom_values.customized_type = 'Issue'
          and custom_values.custom_field_id = ?
        join grid_values rf_gv
          on custom_values.id = rf_gv.custom_value_id
          and rf_gv.column = ?
        where issues.tracker_id = ?
          and rf_gv.value = ?",
      grid_cf_id, rf_column_id, tracker_bm, rf], '')).take
  end

  def self.find_bm_issue_by_order(order)

    tracker_bm = Setting.plugin_bm_xls_to_form["tracker_id"]
    grid_cf_id = Setting.plugin_bm_xls_to_form["grid_frs_data"]
    order_column_id = Setting.plugin_bm_xls_to_form["bm_order_field"]

    Issue.select(:id).joins(ActiveRecord::Base.__send__(:sanitize_sql,
      ["join custom_values
          on issues.id = custom_values.customized_id
          and custom_values.customized_type = 'Issue'
          and custom_values.custom_field_id = ?
        join grid_values order_gv
          on custom_values.id = order_gv.custom_value_id
          and order_gv.column = ?
        where issues.tracker_id = ?
          and order_gv.value = ?",
      grid_cf_id, order_column_id, tracker_bm, order], '')).take
  end

  def self.valid_statuses
    Setting.plugin_bm_xls_to_form['req_to_pay_upload_valid_statuses'] || []
  end

  def self.generate_grid_string(issue_data)                                              
    cf_order = Setting.plugin_bm_xls_to_form["bm_order_field"].to_i
    cf_rf = Setting.plugin_bm_xls_to_form["bm_rf_field"].to_i
    cf_ndoc = Setting.plugin_bm_xls_to_form["document_number_field"].to_i
    cf_datapag = Setting.plugin_bm_xls_to_form["payment_date_field"].to_i

    str_grid = '{'

    issue_data.sort.each.with_index do |data, index|
      str_grid << "\"#{index}\"=>{\"#{cf_order}\"=>\"#{data[0]}\", \"#{cf_rf}\"=>\"#{data[2]}\", "
      str_grid << "\"#{cf_ndoc}\"=>\"#{data[5]}\", "
      str_grid << "\"#{cf_datapag}\"=>\"#{data[4].strftime("%d/%m/%Y")}\"},"
    end

    str_grid << '}'
    str_grid.gsub!(',}', '}')
    str_grid
  end

  def self.journal_user
    user_id = Setting.plugin_bm_xls_to_form['auto_change_system_user']
    @journal_user ||= ((user_id.present? && User.find(user_id)) || User.current)
  end
end
