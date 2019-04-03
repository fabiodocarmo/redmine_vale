module BmStatusHelper

  def self.valid_statuses
    Setting.plugin_bm_xls_to_form["recebimento_fiscal_valid_statuses"] || []
  end

  def self.getTrackersRF()
    trackers = [
        Setting.plugin_bm_xls_to_form["tracker_nfse_id"].to_i,
        Setting.plugin_bm_xls_to_form["tracker_nfse_id2"].to_i,

        Setting.plugin_bm_xls_to_form["tracker_utilities_id"].to_i,
        Setting.plugin_bm_xls_to_form["tracker_utilities_id2"].to_i,
        Setting.plugin_bm_xls_to_form["tracker_utilities_id3"].to_i,
        Setting.plugin_bm_xls_to_form["tracker_utilities_id4"].to_i
    ]

    return trackers
  end

  def self.getTrackersOrder()
    trackers = [
        Setting.plugin_bm_xls_to_form["tracker_utilities_id5"].to_i,
        Setting.plugin_bm_xls_to_form["tracker_utilities_id6"].to_i,

        Setting.plugin_bm_xls_to_form["tracker_materials"].to_i
    ]

    return trackers + self.getTrackersRF()
  end



  def self.getPriorityFromStatus(status)
    return case status
             when Setting.plugin_bm_xls_to_form["status_nfse_rejeitado"].to_i
               Setting.plugin_bm_xls_to_form["nfse_rejeitado_priority"].to_i

             when Setting.plugin_bm_xls_to_form["status_nfse_em_divergencia"].to_i
               Setting.plugin_bm_xls_to_form["nfse_em_divergencia_priority"].to_i

             when Setting.plugin_bm_xls_to_form["status_nfse_novo"].to_i
               Setting.plugin_bm_xls_to_form["nfse_novo_priority"].to_i

             when Setting.plugin_bm_xls_to_form["status_nfse_em_andamento"].to_i
               Setting.plugin_bm_xls_to_form["nfse_em_andamento_priority"].to_i

             when Setting.plugin_bm_xls_to_form["status_nfse_analise"].to_i
               Setting.plugin_bm_xls_to_form["nfse_analise_priority"].to_i

             when Setting.plugin_bm_xls_to_form["status_nfse_em_cadastro"].to_i
               Setting.plugin_bm_xls_to_form["nfse_em_cadastro_priority"].to_i

             when Setting.plugin_bm_xls_to_form["status_nfse_cadastrado"].to_i
               Setting.plugin_bm_xls_to_form["nfse_cadastrado_priority"].to_i
           end
  end

  def self.getStatusFromPriority(priority)
    return case priority
             # Rejeitado
             when Setting.plugin_bm_xls_to_form["nfse_rejeitado_priority"].to_i
               Setting.plugin_bm_xls_to_form["status_bm_rejeitado"].to_i

             # Em Divergência
             when Setting.plugin_bm_xls_to_form["nfse_em_divergencia_priority"].to_i
               Setting.plugin_bm_xls_to_form["status_bm_em_divergencia"].to_i

             # Não Recebida. Isso nunca deveria executar, mas está aqui por segurança
             when Setting.plugin_bm_xls_to_form["nfse_not_received_priority"].to_i
               Setting.plugin_bm_xls_to_form["status_bm_not_received"].to_i

             # Novo
             when Setting.plugin_bm_xls_to_form["nfse_novo_priority"].to_i
               Setting.plugin_bm_xls_to_form["status_bm_novo"].to_i

             # Em Andamento
             when Setting.plugin_bm_xls_to_form["nfse_em_andamento_priority"].to_i
               Setting.plugin_bm_xls_to_form["status_bm_em_andamento"].to_i

             # Em Análise
             when Setting.plugin_bm_xls_to_form["nfse_analise_priority"].to_i
               Setting.plugin_bm_xls_to_form["status_bm_analise"].to_i

             # Em Cadastro
             when Setting.plugin_bm_xls_to_form["nfse_em_cadastro_priority"].to_i
               Setting.plugin_bm_xls_to_form["status_bm_em_cadastro"].to_i

             # Cadastrado
             when Setting.plugin_bm_xls_to_form["nfse_cadastrado_priority"].to_i
               Setting.plugin_bm_xls_to_form["status_bm_cadastrado"].to_i

             # Também nunca deveria acontecer, está aqui por segurança
             else
               Setting.plugin_bm_xls_to_form["status_bm_not_received"].to_i
           end
  end

end