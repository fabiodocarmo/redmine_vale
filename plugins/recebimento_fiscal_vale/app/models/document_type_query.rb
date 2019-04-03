class DocumentTypeQuery < ActiveRecord::Base
  unloadable

  scope :find_by_issue, lambda { |issue|
    where('(project_id     = ? or all_projects    = true)', issue.project_id).
    where('(tracker_id     = ? or all_trackers    = true)', issue.tracker_id).
    where('(status_from_id = ? or (status_from_id is NULL and ? is NULL) or all_status_from = true)', issue.status_id_was, issue.status_id_was).
    where(status_to_id: issue.status_id)
  }

  belongs_to :project
  belongs_to :tracker

  belongs_to :status_from     , class_name: 'IssueStatus'
  belongs_to :status_to       , class_name: 'IssueStatus'
  belongs_to :not_found_status, class_name: 'IssueStatus'
  belongs_to :invalid_status  , class_name: 'IssueStatus'
  belongs_to :not_found_custom_field    , class_name: 'IssueCustomField'
  belongs_to :invalid_custom_field      , class_name: 'IssueCustomField'
  belongs_to :document_custom_field     , class_name: 'IssueCustomField'
  belongs_to :document_type_custom_field, class_name: 'IssueCustomField'

  has_many :document_type_query_configs, dependent: :destroy
  accepts_nested_attributes_for :document_type_query_configs, reject_if: :all_blank, allow_destroy: true


  # NÂO FUNCIONA POR MAIS DE UM GRID
  def queries(issue)
    JSON.parse(issue.custom_value_for(grid_item_custom_field_id).value.gsub("=>", ":")).values.select do |row|
      row[item_custom_field_id.to_s].present?   #DESCARTA LINHAS EM BRANCO SALVAS PELO GRID
    end.map do |row|
      [['pedido', issue.custom_field_value(document_custom_field)], ['item', row[item_custom_field_id.to_s]]].to_h
    end
  end

  def perform(user_id, issue_id, document_type_query_id, retry_num)
    user  = User.find(user_id)
    issue = Issue.find(issue_id)

    return if issue.status_id != status_to_id

    document_type = DocumentTypeQueryResource.document_type(self, issue)
    error_status  = nil

    message_custom_fields = {}

    unless document_type
      if Setting.plugin_recebimento_fiscal_vale['retry_num'] && Setting.plugin_recebimento_fiscal_vale['retry_num'].to_i > retry_num
        AsyncDocumentTypeQuery.set(wait_until: Time.zone.now + Setting.plugin_recebimento_fiscal_vale['retry_after'].to_i.seconds)
                              .perform_later(user_id, issue_id, document_type_query_id, retry_num + 1)
        return true
      else
        error_status ||= not_found_status

        message_custom_fields = {
          not_found_custom_field_id => "* #{not_found_message}\n"
        }
      end
    end

    issue.init_journal(user, "")

    if error_status
      issue.custom_field_values = message_custom_fields
      issue.status = error_status
    else
      document_type_query_config = document_type_query_configs.find_by_document_type(document_type['document_type'])

      if document_type_query_config
        issue.custom_field_values = { document_type_custom_field_id => document_type_query_config.document_type }
        issue.status              = document_type_query_config.status
      else
        error_status = invalid_status

        message_custom_fields = {
          invalid_custom_field_id => "* #{invalid_message}\n"
        }

        issue.custom_field_values = message_custom_fields
        issue.status              = error_status
      end
    end

    issue.save(validate: false)
  end

end
