class AddNameToImportTemplate < ActiveRecord::Migration
  def change
    add_column :import_templates, :name, :text
  end
end
