class CreateApiIntegrations < ActiveRecord::Migration
  def change
    create_table :api_integrations do |t|
      t.integer :project_id
      t.integer :tracker_id, unique: true
    end
  end
end
