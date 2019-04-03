# encoding: UTF-8
class MailerController < ApplicationController

  helper :queries
  include QueriesHelper
  helper :sort
  include SortHelper

  def export_to_email
    puts l(:sending_mail_message)
    @project = session[:query][:project_id]

    csv = ExportToEmailJob.new(params.to_hash, session.to_hash, @project, User.current.id).csv_to_mail

    h = {:status => "OK"}
    render :json => h
  end
end
