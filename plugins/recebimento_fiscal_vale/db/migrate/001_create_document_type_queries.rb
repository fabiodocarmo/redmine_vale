class CreateDocumentTypeQueries < ActiveRecord::Migration
  def change
    create_table :document_type_queries do |t|
      t.integer :project_id
      t.boolean :all_projects
      t.integer :tracker_id
      t.boolean :all_trackers
      t.integer :status_from_id
      t.boolean :all_status_from
      t.integer :status_to_id

      t.integer :not_found_status_id
      t.integer :not_found_custom_field_id
      t.text    :not_found_message

      t.integer :invalid_status_id
      t.integer :invalid_custom_field_id
      t.text    :invalid_message

      t.integer :document_custom_field_id
      t.integer :document_type_custom_field_id

      t.integer :grid_item_custom_field_id
      t.integer :item_custom_field_id
    end
  end
end
