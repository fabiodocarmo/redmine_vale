module RedmineApiIntegrations
  module Patches
    module IssueStatusesControllerPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          before_filter :show_status, only: [:index], if: :api_request?
          before_filter :possible_status, only: [:show], if: :api_request?
          before_filter :require_admin, except: [:show, :index]
          before_filter :require_admin_or_api_request, only: [:show, :index]
          accept_api_auth :show, :index
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def show_status
          if params[:status_id].present?
            begin
              @status = IssueStatus.find(params[:status_id])
            rescue ActiveRecord::RecordNotFound => e
              @status = nil
            end
          else
            @status = IssueStatus.all.order(:id)
          end

          respond_to do |format|
            format.api { render :action => 'index' } if !params[:status_id].present?
            format.api { render :action => 'not_found' } if @status.nil?
            format.api { render :action => 'show' } 
          end
        end

        def possible_status
          begin
            issue = Issue.find(params[:issue_id])
          rescue ActiveRecord::RecordNotFound => e
            issue = nil
          end

          begin
            user = User.find(params[:user_id])
          rescue ActiveRecord::RecordNotFound => e
            user = nil
          end

          if !issue.nil?
            @possible_statuses = issue.new_statuses_allowed_to(user)
          end

          if user.nil? or issue.nil?
            respond_to do |format|
              format.api  { render :action => 'not_found', :status => 404 }
            end
          else
            respond_to do |format|
              format.api  { render :action => 'possible_statuses' }
            end
          end

        end
      end
    end
  end
end
