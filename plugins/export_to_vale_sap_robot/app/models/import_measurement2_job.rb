class ImportMeasurement2Job < ActiveJob::Base
  queue_as :upload_sap_robot

  def perform(file_path, user_id)
    ExportToValeSapRobot::Services::ImportNfs.import_measurement2_log(file_path, 0, 1, 8, 9, 10, 11)
    NfRobotUploaderMailer.notify_success(User.find(user_id)).deliver
  end
end
