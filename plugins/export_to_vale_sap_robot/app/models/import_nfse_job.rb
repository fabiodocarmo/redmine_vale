class ImportNfseJob < ActiveJob::Base
  queue_as :upload_sap_robot

  def perform(file_path, user_id, project_identifier, log_type, issue_id_col, current_status_id, new_status_id, journal_msg_col, custom_field_cols)
    ExportToValeSapRobot::Services::ImportNfs.import_nfse_log(file_path, user_id,
      project_identifier, log_type, issue_id_col, current_status_id, new_status_id, journal_msg_col, custom_field_cols)
    NfRobotUploaderMailer.notify_success(User.find(user_id)).deliver
  end
end
