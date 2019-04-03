class DocumentTypeQueryResource
  include HTTParty

  base_uri Setting.plugin_recebimento_fiscal_vale['base_url']

  INVALID = 0

  def self.document_type(document_type_query, issue)
    doc_types = document_type_query
                             .queries(issue)
                             .map { |q| JSON.parse(get("/document_types", { query: q }).body).first  }
                             .uniq
    if doc_types.count > 1
      { document_type: INVALID }
    else
      doc_types.first
    end
  end
end
