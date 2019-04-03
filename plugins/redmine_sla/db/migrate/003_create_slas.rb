class CreateSlas < ActiveRecord::Migration
  def change
    create_table :slas do |t|
      t.string :name
      t.references :office_hour, index: true, foreign_key: true
      t.references :custom_field, index: true, foreign_key: true
      t.float :sla
    end

    create_table :projects_slas do |t|
      t.references :sla, index: true, foreign_key: true
      t.references :project, index: true, foreign_key: true
    end

    create_table :slas_trackers do |t|
      t.references :sla, index: true, foreign_key: true
      t.references :tracker, index: true, foreign_key: true
    end

    create_table :issue_statuses_slas do |t|
      t.references :sla, index: true, foreign_key: true
      t.references :issue_status, index: true, foreign_key: true
    end

    create_table :enumerations_slas do |t|
      t.references :sla, index: true, foreign_key: true
      t.references :enumeration, index: true, foreign_key: true
    end
  end
end
