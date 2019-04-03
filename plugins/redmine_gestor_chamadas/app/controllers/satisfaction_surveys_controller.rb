# encoding: UTF-8
class SatisfactionSurveysController < ApplicationController
  unloadable

  before_filter :build_new, only: [:new]
  before_filter :find_satisfaction, only: [:show]
  before_filter :build_new_from_api, only: [:create], if: :api_request?
  accept_api_auth :create


  layout 'public_layout'

  def new
    if params[:error] != '0' && !params[:error].blank?
      error_list = Array.new
      error_list = params[:error].split('/')
      for error in error_list do
        if error == 'nota'
          @satisfaction.errors.add('satisfaction',l(:satisfaction_missing))
        elsif error == 'reabertura'
          @satisfaction.errors.add('issue_reopened', l(:satisfaction_issue_reopened))
        else error == 'comentario'
          @satisfaction.errors.add('comment',l(:satisfaction_message))
        end
      end
    end
  end

  def create
    issue_id = params[:satisfaction_survey][:issue_id] || params[:issue_id]
    @issue = Issue.find(issue_id)
    if @issue && @issue.show_satisfaction_survey? == true
      @satisfaction = SatisfactionSurvey.new()
      @satisfaction.satisfaction = params[:satisfaction_survey][:satisfaction].nil? ? nil : params[:satisfaction_survey][:satisfaction].split[0]
      @satisfaction.satisfaction_level = params[:satisfaction_survey][:satisfaction].nil? ? nil : params[:satisfaction_survey][:satisfaction].split[1]
      @satisfaction.comment = params[:satisfaction_survey][:comment]
      @satisfaction.issue_reopened = params[:satisfaction_survey][:issue_reopened]
      @satisfaction.issue_id = issue_id
      @satisfaction.enable_reopen = params[:satisfaction_survey][:enable_reopen].nil? ? false : params[:satisfaction_survey][:enable_reopen].split[0]
      @satisfaction.question = params[:satisfaction_survey][:enable_reopen].nil? ? 'não aplicável' : params[:satisfaction_survey][:enable_reopen].split(' ')[1..-1].join(' ')
      msg_erro = Array.new
      if @satisfaction.satisfaction.nil?
        msg_erro << "nota"
      end

      if @satisfaction.enable_reopen.nil?
        msg_erro << "reabertura"
      end

      if @satisfaction.comment.blank?
        msg_erro << "comentario"
      end

      if @satisfaction.satisfaction != 'satisfeito' && (@satisfaction.comment.blank? || @satisfaction.enable_reopen.nil?)
        redirect_to new_satisfaction_survey_path(issue_id, msg_erro)
        return
      end
      if @satisfaction.save
        redirect_to issue_path(issue_id), notice: l(:answer_sucessfully_sent_message)
      else
        render :new
      end
    else
      redirect_to issue_path(issue_id), {flash: {error: l(:satisfaction_survey_already_answered)}}
    end
  end

  def show;  end

  def find_satisfaction
    @satisfaction = SatisfactionSurvey.find(params[:id])
  end

  def build_new
    return unless @satisfaction.blank?
    if params[:issue_id]
      @issue = Issue.find(params[:issue_id])
      if @issue && @issue.author == User.current && @issue.show_satisfaction_survey? == true
        @satisfaction = SatisfactionSurvey.new()
        return nil
      end
    end
    render_404
  end

  def build_new_from_api
    return unless @satisfaction.blank?
    if params[:issue_id] and params[:user_id]
      @issue = Issue.find(params[:issue_id])
      User.current = User.find(params[:user_id])
      if @issue && @issue.author == User.current && @issue.show_satisfaction_survey? == true
        self.create_from_api
        respond_to do |format|
          format.api  { render :action => 'create_success' } 
        end
        return
      end
    end
    render_404
  end

  def create_from_api
    issue_id = params[:issue_id]
    @issue = Issue.find(issue_id)
    if @issue && @issue.show_satisfaction_survey? == true
      @satisfaction = SatisfactionSurvey.new()
      @satisfaction.issue_id = issue_id
      @satisfaction.satisfaction_level = params[:satisfaction_level].nil? ? nil : params[:satisfaction_level]
      @satisfaction.comment = params[:comment]

      if @satisfaction.satisfaction_level <= 6 then
        @satisfaction.issue_reopened = true
        @satisfaction.enable_reopen = true
        @satisfaction.satisfaction = "nao_satisfeito"
      else
        @satisfaction.issue_reopened = false
        @satisfaction.enable_reopen = false
        @satisfaction.satisfaction = "satisfeito"
      end
      
      @satisfaction.question = !@satisfaction.enable_reopen ? 'não aplicável' : l(:response_question)
     
      @satisfaction.save
    else
      render_422
    end
  end


end
