class CreateImportTemplates < ActiveRecord::Migration
  def change
    create_table :import_templates do |t|
      t.references :user, index: true

      t.text :settings
    end
  end
end
