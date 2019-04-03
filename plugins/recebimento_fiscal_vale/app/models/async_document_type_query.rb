class AsyncDocumentTypeQuery < ActiveJob::Base
  queue_as :document_type_queries

  def perform(user_id, issue_id, document_type_query_id, retry_num)
    DocumentTypeQuery.find(document_type_query_id).perform(user_id, issue_id, document_type_query_id, retry_num)
  end
end
