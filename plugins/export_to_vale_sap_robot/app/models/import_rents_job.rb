class ImportRentsJob < ActiveJob::Base
  queue_as :upload_sap_robot

  def perform(file_path, user_id)
    ExportToValeSapRobot::Services::ImportNfs.import_rents_log(file_path, 21, 13, 14)
    NfRobotUploaderMailer.notify_success(User.find(user_id)).deliver
  end
end
