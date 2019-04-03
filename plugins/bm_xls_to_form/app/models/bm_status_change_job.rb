class BMStatusChangeJob < ExecJob
  unloadable

  def perform(issue)
    issue = issue.is_a?(Issue) ? issue : Issue.find(issue)

    updated = false

    if BmStatusHelper.getTrackersRF().include? issue.tracker_id
      begin
        updated = updateStatusByRF(issue)
      rescue => e
        Delayed::Worker.logger.error("BMStatusChangeJob: erro ao atualizar status pelo RF.\n#{e.backtrace}")
      end
    end

    if not updated
      begin
        updateStatusByOrder(issue)
      rescue => e
        Delayed::Worker.logger.error("BMStatusChangeJob: erro ao atualizar status pelo pedido.\n#{e.backtrace}")
      end
    end

  end

  def updateStatusByOrder(issue)
    trackers_nf  = BmStatusHelper.getTrackersOrder()
    tracker_bm  = Setting.plugin_bm_xls_to_form["tracker_id"].to_i
    order_nfse_id  = Setting.plugin_bm_xls_to_form["nfse_order_field"].to_i
    order_mat_id = Setting.plugin_bm_xls_to_form["mat_order_field"].to_i
    order_bm_id    = Setting.plugin_bm_xls_to_form["bm_order_field"].to_i
    grid_order_id  = Setting.plugin_bm_xls_to_form["grid_frs_data"].to_i


    validStatus = BmStatusHelper.valid_statuses()

    order_issue  = issue.custom_field_value(order_nfse_id)

    if (order_issue.nil? or order_issue.to_s == "") # É nota de Material
      order_issue  = issue.custom_field_value(order_mat_id)
    end

    issues_bm = Issue.joins(custom_values: [:grid_values])
                    .where(tracker_id: tracker_bm, status_id: validStatus)
                    .where(grid_values: {value: order_issue, column: order_bm_id})

    # Não foi encontrado nenhum BM com Pedido associado
    if (issues_bm.nil? or issues_bm.length == 0)
      return false
    end

    savedOnce = false

    issues_bm.each do |issue_bm|

      # Procuro as issues do recebimento fiscal que tenham as RFs do BM
      grid_lines = JSON.parse issue_bm.custom_field_value(grid_order_id).gsub('=>',':')

      orders = grid_lines.map { |_index_linha, dados| dados[order_bm_id.to_s] }
      orders = orders.uniq

      qtdOrders = orders.length

      issues_nf = Issue.joins(:custom_values)
                      .where(tracker_id: trackers_nf)
                      .where(custom_values: {value_hashed: orders.map{|ord| Digest::SHA256.hexdigest(ord)},
                                             value: orders,
                                             custom_field_id: order_nfse_id})

      issues_mat = Issue.joins(:custom_values)
                       .where(tracker_id: trackers_nf)
                       .where(custom_values: {value_hashed: orders.map{|ord| Digest::SHA256.hexdigest(ord)},
                                              value: orders,
                                              custom_field_id: order_mat_id})

      issues_nf = issues_nf + issues_mat

      # Não foi encontrado nenhuma NF com Pedido associado
      # Isso nunca deveria ocorrer, pois para chegar até aqui a issue que gerou esse exec job deve
      #  ter um Pedido relacionado a algum BM
      # Este trecho está aqui por segurança
      if (issues_nf.nil? or issues_nf.length == 0)
        journal = issue_bm.init_journal(journal_user)
        journal.notify = false
        issue_bm.status_id = Setting.plugin_bm_xls_to_form["status_bm_not_received"].to_i
        issue_bm.save
        savedOnce = true
        next
      end

      # Número qualquer que será sobrescrito na primeira rodada
      # Está aqui apenas para declarar a variável e seu tipo
      priority = 0

      # Declaro um hash para armazenar os status das RFs unicamente
      uniqueOrders = {}

      # Varro as issues e armazeno o melhor status para aquele Pedido unicamente
      # Exemplo:
      # IssueId = 1, Pedido = 123, Status = Nota Rejeitada
      # IssueId = 3, Pedido = 123, Status = Nota em Análise
      # Será mantido o status Nota em Análise por ser o melhor

      issues_nf.each do |issue_nf|
        status = issue_nf.status_id
        order = issue_nf.custom_field_value(order_nfse_id)

        if order.nil? # Não é nota de utilities, é de material
          order = issue_nf.custom_field_value(order_mat_id)
        end

        if uniqueOrders.key?(order)
          # O Pedido já existe no hash. Fico com o de melhor status
          status_hash = uniqueOrders[order]
          priority_hash = BmStatusHelper.getPriorityFromStatus(status_hash)
          priority = BmStatusHelper.getPriorityFromStatus(status)

          if priority>priority_hash # Se a prioridade atual indicar um status melhor que a do hash, substituo a do hash
            uniqueOrders[order] = status
          end

        else  # A RF não está no hash, adiciono-a no hash
          uniqueOrders = uniqueOrders.merge(Hash[order, status])
        end
      end

      priority = 0
      first_run = true

      # Há mais Pedidos registrados no chamado do BM que existem chamados de notas com esses Pedidos
      # Isso indica que uma (ou mais) nota ainda não foi cadastrada para algum Pedido do chamado do BM
      if qtdOrders>uniqueOrders.length
        priority = Setting.plugin_bm_xls_to_form["nfse_not_received_priority"].to_i
        first_run = false
      end

      uniqueOrders.each do |key, value|
        status = value

        priority_new = BmStatusHelper.getPriorityFromStatus(status)

        # A prioridade de menor valor (mais crítica) permanece
        if priority_new<priority or first_run
          priority = priority_new
          first_run = false
        end

      end

      # Tendo a prioridade definida, podemos salvar o status da issue do BM
      #  com o status apropriado de acordo com a prioridade

      status_bm = BmStatusHelper.getStatusFromPriority(priority)

      issue_bm.status_id=status_bm
      issue_bm.save
      savedOnce = true

    end

    return savedOnce
  end

  def updateStatusByRF(issue)
    trackers_nf  = BmStatusHelper.getTrackersRF()
    tracker_bm  = Setting.plugin_bm_xls_to_form["tracker_id"].to_i
    rf_nfse_id  = Setting.plugin_bm_xls_to_form["nfse_rf_field"].to_i
    rf_bm_id    = Setting.plugin_bm_xls_to_form["bm_rf_field"].to_i
    grid_rf_id  = Setting.plugin_bm_xls_to_form["grid_rf_data"].to_i

    validStatus = BmStatusHelper.valid_statuses()

    rf_issue  = issue.custom_field_value(rf_nfse_id)

    return false if rf_issue.blank?

    issues_bm = Issue.joins(custom_values: [:grid_values])
                    .where(tracker_id: tracker_bm, status_id: validStatus)
                    .where(grid_values: {value: rf_issue, column: rf_bm_id})

    issue_bm = issues_bm.first # so deve existir uma issue de BM. Se houver mais de uma, indica duplicata

    # Não foi encontrado nenhum BM com RF associada
    if issue_bm.nil?
      return false
    end

    # Procuro as issues do recebimento fiscal que tenham as RFs do BM
    grid_lines = JSON.parse issue_bm.custom_field_value(grid_rf_id).gsub('=>',':')

    rfs = grid_lines.map { |_index_linha, dados| dados[rf_bm_id.to_s] }
    rfs = rfs.uniq

    qtdRfs = rfs.length

    issues_nf = Issue.joins(:custom_values)
                    .where(tracker_id: trackers_nf)
                    .where(custom_values: {value_hashed: rfs.map{|r| Digest::SHA256.hexdigest(r)},
                                           value: rfs,
                                           custom_field_id: rf_nfse_id})

    # Não foi encontrado nenhuma NF com RF associada
    # Isso nunca deveria ocorrer, pois para chegar até aqui a issue que gerou esse exec job deve
    #  ter uma RF relacionada a algum BM
    # Este trecho está aqui por segurança
    if issues_nf.nil?
      issue_bm.status_id = Setting.plugin_bm_xls_to_form["status_bm_not_received"].to_i
      issue_bm.save
      return true
    end

    # Número qualquer que será sobrescrito na primeira rodada
    # Está aqui apenas para declarar a variável e seu tipo
    priority = 0

    # Declaro um hash para armazenar os status das RFs unicamente
    uniqueRfs = {}

    # Varro as issues e armazeno o melhor status para aquela RF unicamente
    # Exemplo:
    # IssueId = 1, RF = 123, Status = Nota Rejeitada
    # IssueId = 3, RF = 123, Status = Nota em Análise
    # Será mantido o status Nota em Análise por ser o melhor

    issues_nf.each do |issue_nf|
      status = issue_nf.status_id
      rf = issue_nf.custom_field_value(rf_nfse_id)
      if uniqueRfs.key?(rf)
        # A RF já existe no hash. Fico com a de melhor status
        status_hash = uniqueRfs[rf]
        priority_hash = BmStatusHelper.getPriorityFromStatus(status_hash)
        priority = BmStatusHelper.getPriorityFromStatus(status)

        if priority>priority_hash # Se a prioridade atual indicar um status melhor que a do hash, substituo a do hash
          uniqueRfs[rf] = status
        end

      else  # A RF não está no hash, adiciono-a no hash
        uniqueRfs = uniqueRfs.merge(Hash[rf, status])
      end
    end

    priority = 0
    first_run = true

    # Há mais RFs registradas no chamado do BM que existem chamados de notas com essas RFs
    # Isso indica que uma (ou mais) nota ainda não foi cadastrada para alguma RF do chamado do BM
    if qtdRfs>uniqueRfs.length
      priority = Setting.plugin_bm_xls_to_form["nfse_not_received_priority"].to_i
      first_run = false
    end

    uniqueRfs.each do |key, value|
      status = value

      priority_new = BmStatusHelper.getPriorityFromStatus(status)

      # A prioridade de menor valor (mais crítica) permanece
      if priority_new<priority or first_run
        priority = priority_new
        first_run = false
      end

    end

    # Tendo a prioridade definida, podemos salvar o status da issue do BM
    #  com o status apropriado de acordo com a prioridade

    status_bm = BmStatusHelper.getStatusFromPriority(priority)

    journal = issue_bm.init_journal(journal_user)
    journal.notify = false
    issue_bm.status_id=status_bm
    issue_bm.save

    return true
  end

  def schema
    {
        # constant_text: {
        #     field_type: :text
        # },
        # constant_string: {
        #     field_type: :string
        # },
        # constant_password: {
        #     field_type: :password
        # },
        # constant_number: {
        #     field_type: :number
        # },
        # constant_date: {
        #     field_type: :date
        # },
        # constant_boolean: {
        #     field_type: :boolean
        # },
        new_status: {
            field_type: :collection,
            model: 'IssueStatus',
            key: :name,
        },
        # constant_many: {
        #   field_type: :many,
        #   fields: {
        #     constant_text: {
        #       field_type: :text
        #     },
        #     constant_string: {
        #       field_type: :string
        #     }
        #   }
        # }
    }
  end

  private

  def journal_user
    @journal_user ||= User.find(Setting.plugin_bm_xls_to_form['auto_change_system_user'])
  end

end
