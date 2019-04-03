class ImportXlsxIssueJob < ActiveJob::Base
  queue_as :import_xlsx_issue_job

  def perform(import, user_id)
    @saved_issues = Import::Services::ImportXlsxIssues.import_xlsx_issues(import)
    ImportIssueUploaderMailer.notify_success(User.find(user_id), @saved_issues).deliver
  end
end
