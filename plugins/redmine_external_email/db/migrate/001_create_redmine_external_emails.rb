class CreateRedmineExternalEmails < ActiveRecord::Migration
  def change
    create_table :redmine_external_emails do |t|
      t.integer :project_id
      t.boolean :all_projects
      t.integer :tracker_id
      t.boolean :all_trackers
      t.integer :status_from_id
      t.boolean :all_status_from
      t.integer :status_to_id

      t.integer :email_custom_field_id
      t.string  :subject
      t.text    :body
      t.boolean :send_attachments
    end
  end
end
