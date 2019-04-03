module RedmineApiIntegrations
  module Patches
    module WatchersControllerPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          before_filter :add_watcher, only: [:create], if: :api_request?
          before_filter :remove_watcher, only: [:destroy], if: :api_request?
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def add_watcher
          user_ids = []
          user_ids << params[:user_id]
          
          @users = User.active.visible.where(:id => user_ids.flatten.compact.uniq)

          unless @users.empty?
            @users.each do |user|
              @watchables.each do |watchable|
                Watcher.create(:watchable => watchable, :user => user)
              end
            end
          end

          respond_to do |format|
            format.api  { render :action => 'error', :status => :unprocessable_entity } if @users.empty?
            format.api  { render :action => 'added' }
          end
        end

        def remove_watcher
          begin
            user = User.find(params[:user_id])
          rescue ActiveRecord::RecordNotFound => e
            user = nil
          end

          unless user.nil?
            flag = false
            @watchables.each do |watchable|
              if watchable.watcher_user_ids.include?(user.id)
                watchable.set_watcher(user, false)
                flag = true
              end
            end
          end

          respond_to do |format|
            format.api  { render :action => 'error', :status => :unprocessable_entity } if user.nil?
            format.api  { render :action => 'user_error', :status => :unprocessable_entity } if !flag 
            format.api  { render :action => 'removed' }
          end
        end
      end
    end
  end
end
