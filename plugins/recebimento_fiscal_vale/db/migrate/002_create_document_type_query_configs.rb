class CreateDocumentTypeQueryConfigs < ActiveRecord::Migration
  def change
    create_table :document_type_query_configs do |t|
      t.integer :document_type_query_id

      t.string :document_type
      t.integer :status_id
    end
  end
end
