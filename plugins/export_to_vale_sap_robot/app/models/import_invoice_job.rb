class ImportInvoiceJob < ActiveJob::Base
  queue_as :upload_sap_robot

  def perform(file_path, user_id)
    ExportToValeSapRobot::Services::ImportNfs.import_invoice_log(file_path, 19, 13, 14)
    NfRobotUploaderMailer.notify_success(User.find(user_id)).deliver
  end
end
