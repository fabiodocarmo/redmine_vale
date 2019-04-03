module PacConsultoriaGeral
    module Services
        # Classe para pegar as datas de aprovações do PAC
        class AprovacoesService

            # Pega a última aprovação dado chamado e a aprovação
            def self.get_aprovacao(issue, aprovacao_cf_id)
                begin
                    issue = issue.is_a?(Issue) ? issue : Issue.find(issue)
                    journals = Journal.where(journalized_id: issue).joins(:details).where("journal_details.prop_key = '#{aprovacao_cf_id.to_s}'").last
                    if journals
                        journals.created_on.strftime("%d/%m/%Y") + "  Assinatura eletrônica. Chamado: # #{issue.id}"
                    else
                        "____/____/______  Ass.:........................................................................"
                    end
                rescue
                    "____/____/______  Ass.:........................................................................"
                end
            end

        end
    end 
end