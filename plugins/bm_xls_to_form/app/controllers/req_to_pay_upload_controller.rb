class ReqToPayUploadController < ApplicationController

  before_filter :find_project_by_project_id, :authorize

  class NoFileUploadedError < StandardError
  end

  def upload

    if matched_extension = params[:req_to_pay_upload_filename].original_filename.match(/\.(xlsx?)$/)
      @attachment = Attachment.new(file: params[:req_to_pay_upload_filename].tempfile)
      @attachment.author = User.current
      @attachment.filename = Redmine::Utils.random_hex(16)
      @attachment.content_type = params[:req_to_pay_upload_filename].content_type
      @attachment.description = matched_extension[1]
      @attachment.save!
      ReqToPayUploadJob.perform_later(@attachment.id, User.current.id)
      flash[:notice] = l(:enqueued_request)
    else
      flash[:error] = l(:req_to_pay_upload_invalid_file)
    end

    redirect_to action: :index, project_id: params[:project_id]
  end
end
