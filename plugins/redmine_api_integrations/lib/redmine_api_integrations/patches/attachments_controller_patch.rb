module RedmineApiIntegrations
  module Patches
    # Patches Redmine's Issues Controller dynamically.  Adds a +after_save+ filter.
    module AttachmentsControllerPatch
      def self.included(base) # :nodoc
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          before_filter :upload_file, only: [:upload], if: :api_request?
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def upload_file
          # Make sure that API users get used to set this content type
          # as it won't trigger Rails' automatic parsing of the request body for parameters
          unless request.content_type == 'application/octet-stream'
            render :nothing => true, :status => 406
            return
          end

          @attachment = Attachment.new(:file => request.raw_post)
          @attachment.author = User.current
          @attachment.filename = params[:filename].presence || Redmine::Utils.random_hex(16)
          @attachment.content_type = params[:content_type].presence
          
          saved = @attachment.save

          respond_to do |format|
            format.api {
              if saved
                render :action => 'upload', :status => :created
              else
                self.render_validation_errors(@attachment)
              end
            }
          end
        end

        def render_validation_errors(objects)
          messages = Array.wrap(objects).map {|object| object.errors.full_messages}.flatten
          self.render_api_errors(messages)
        end

        def render_api_errors(*messages)
          @error_messages = messages.flatten
          render :template => 'common/errors.api', :status => :unprocessable_entity, :layout => nil
        end
      end
    end
  end
end
