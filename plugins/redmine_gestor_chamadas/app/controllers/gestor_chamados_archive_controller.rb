# encoding: UTF-8
class GestorChamadosArchiveController < ApplicationController
  unloadable
  accept_api_auth :index, :show, :create, :update, :destroy

  def archive_issue
    issue_id = params[:id]
    issue = Issue.find(issue_id)
    @user = User.find(params[:user])

    @new_journal = Journal.new(:journalized => issue, :user => @user)
    @new_journal.details << JournalDetail.new(:property => 'attr', :prop_key => 'status_id',:old_value => issue.status_id, :value => Setting.plugin_redmine_gestor_chamadas[:archived_status])
    issue.journals << @new_journal

    issue.status_id = Setting.plugin_redmine_gestor_chamadas[:archived_status]
    issue.save

    redirect_to issue_path(issue_id)
  end

end
