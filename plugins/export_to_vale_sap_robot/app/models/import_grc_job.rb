# encoding: utf-8
class ImportGrcJob < ActiveJob::Base
  queue_as :upload_sap_robot

  def perform(file_path, user_id, project_identifier)
    ExportToValeSapRobot::Services::ImportNfs.import_grc_report(file_path, user_id, project_identifier)
    NfRobotUploaderMailer.notify_success(User.find(user_id)).deliver
  end
end
