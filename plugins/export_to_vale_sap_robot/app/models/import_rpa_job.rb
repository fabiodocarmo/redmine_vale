class ImportRpaJob < ActiveJob::Base
  queue_as :upload_sap_robot

  def perform(file_path, user_id)
    ExportToValeSapRobot::Services::ImportNfs.import_rpa_log(file_path, 0, 14, 15)
    NfRobotUploaderMailer.notify_success(User.find(user_id)).deliver
  end
end
