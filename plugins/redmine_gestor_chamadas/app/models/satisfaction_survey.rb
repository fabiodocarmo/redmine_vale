# encoding: UTF-8
class SatisfactionSurvey < ActiveRecord::Base
  unloadable

  belongs_to :issue
  # validates :satisfaction, :inclusion => {:in => [true,false], :message => :satisfaction_missing}
  # validates :comment, :presence => { :unless => "satisfaction == 'satisfeito'", :message => :satisfaction_comment}
  after_save :archive_or_reopen , if: '!satisfaction.blank?'
  # validates :issue_reopened, :inclusion => {:unless => "satisfaction == 'satisfeito'", :in =>[true, false], :message => :satisfaction_issue_reopened}

  def archive_or_reopen
    if self.satisfaction == 'satisfeito'
      journal_notes = l(:journal_notes_positive_message)
      journal_notes += l(:comments_label) +': '+ self.comment unless self.comment.blank?
      self.issue.archive(User.current, journal_notes)
    elsif self.issue_reopened.blank? || self.issue_reopened == false
      journal_notes = l(:journal_notes_neutral_message)
      journal_notes += l(:comments_label) +': '+ self.comment unless self.comment.blank?
      self.issue.archive(User.current, journal_notes)
    else
      journal_notes = l(:journal_notes_negative_message)
      journal_notes += l(:comments_label) +': '+ self.comment unless self.comment.blank?
      self.issue.reopen_not_satisfied(User.current, journal_notes, Setting.plugin_redmine_gestor_chamadas[:reopen_status_to])
    end
  end

  def validate_comment
    errors.add('comment', l(:journal_notes_feedback_request_message) )
  end

  def validate_issue_reopened
    errors.add('issue_reopened', l(:journal_notes_feedback_request_message_reopened) )
  end
end
