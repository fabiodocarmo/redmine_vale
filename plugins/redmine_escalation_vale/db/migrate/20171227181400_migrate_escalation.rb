class MigrateEscalation < ActiveRecord::Migration
  def change

    create_table :email_templates do |t|
      t.string :name
      t.string :subject
      t.text :template
      t.text :image_url
    end

    create_table :rules do |t|
      t.integer :min_sent
      t.integer :max_sent
      t.string :area
      t.string :hierarchy
      t.string :classification
      t.references :email_template
    end

    create_table :hierarchies do |t|
      t.references :user
      t.references :n1
      t.references :n2
      t.references :n3
      t.references :n4
      t.references :n5
      t.references :n6
      t.references :n7
      t.references :n8
      t.integer :level
    end

    create_table :visibility_reports do |t|
      t.timestamp :created_at
      t.timestamp :updated_at
      t.references :tracker
      t.references :user
      t.references :issue
      t.references :hierarchy
      t.string :supplier_social_name
      t.string :supplier_cnpj
      t.string :classification
      t.string :area
      t.integer :total_aging
      t.integer :phase_aging
      t.integer :sent_number
    end
  end
end
