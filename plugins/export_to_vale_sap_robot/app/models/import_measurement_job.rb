class ImportMeasurementJob < ActiveJob::Base
  queue_as :upload_sap_robot

  def perform(file_path, user_id)
    ExportToValeSapRobot::Services::ImportNfs.import_measurement_log(file_path, 0, 4, 1, 2, 3)
    NfRobotUploaderMailer.notify_success(User.find(user_id)).deliver
  end
end
