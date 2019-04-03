class RenameTables < ActiveRecord::Migration
  def change
    rename_table :office_hours, :vsg_sla_office_hours
    rename_table :working_days, :vsg_sla_working_days
    rename_table :slas, :vsg_sla_slas
    rename_table :sla_reports, :vsg_sla_sla_reports

    rename_table :projects_slas, :projects_vsg_sla_slas
    rename_table :slas_trackers, :trackers_vsg_sla_slas
    rename_table :issue_statuses_slas, :issue_statuses_vsg_sla_slas
    rename_table :enumerations_slas, :enumerations_vsg_sla_slas
  end
end
