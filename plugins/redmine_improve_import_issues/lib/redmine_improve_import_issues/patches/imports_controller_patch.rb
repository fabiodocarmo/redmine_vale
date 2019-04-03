module RedmineImproveImportIssues
  # Patches Redmine's Issues Controller dynamically.  Adds a +after_save+ filter.
  module Patches
    module ImportsControllerPatch

      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen
          alias_method_chain :create, :other_types
          alias_method_chain :new, :other_types
          before_filter :find_import, :only => [:show, :settings, :mapping, :run, :xlsx]
          before_filter :authorize_global, :except => [:form, :xlsx]

        end
      end

      module ClassMethods
      end

      module InstanceMethods

        def form
          @import = Import.new
          @import.settings.merge!(
            'project_id' => params["project_id"],
            'tracker_id' => params["tracker_id"],
            'custom_fields' => params[:selected_columns]
          )
          @default_projects = Project.all.reject { |p| p.trackers.blank?}
          if params["project_id"].blank?
            @import_trackers = []
          else
            @import_trackers = Project.find_by_id(@import.settings["project_id"]).trackers
          end

          if params["tracker_id"].blank?
            @import_custom_fields = []
          else
            @import_custom_fields = Tracker.find_by_id(@import.settings["tracker_id"]).custom_fields.order('custom_fields_trackers.position ASC, custom_fields.position').map {|g| [ g.name,g.id ] }
          end

          @import_templates = ImportTemplate.where(:user_id => User.current.id)

          unless params["import_template_id"].blank?
            @import.settings["project_id"] = @import_templates.where(:id => params["import_template_id"]).first.settings["project_id"]
            @import.settings["tracker_id"] = @import_templates.where(:id => params["import_template_id"]).first.settings["tracker_id"]
            @import.settings["custom_fields"] = @import_templates.where(:id => params["import_template_id"]).first.settings["custom_fields"]

            @import_trackers = Project.find_by_id(@import.settings["project_id"]).trackers
            @import_custom_fields = Tracker.find_by_id(@import.settings["tracker_id"]).custom_fields.order('custom_fields_trackers.position ASC, custom_fields.position').map {|g| [ g.name,g.id ] }
            @import.settings.merge!('selected_template' => params["import_template_id"])
          end
        end

        def create_with_other_types
          @import = IssueImport.new
          @import.user = User.current
          @import.file = params[:file]
          @import.set_default_settings

          accepted_formats = [".xlsx", ".csv"]
          extension_of_file = params[:file] ? verify_file_extension(params[:file].original_filename) : ""
          include_format = accepted_formats.include? extension_of_file

          begin
            if @import.filepath.blank?
              raise "Arquivo deve ser inserido"
            end
            save_file(@import)
          rescue RuntimeError => e
            flash[:error] = e.message
            redirect_to new_issues_import_path
            return
          end

          if @import.save && include_format
            if extension_of_file == ".csv"
              redirect_to import_settings_path(@import)
            else
              redirect_to import_xlsx_path(@import,params)
            end
          else
            render :action => 'new'
            return
          end
        end

        def new_with_other_types
          @import = Import.new
          @default_projects = Project.all.reject { |p| p.trackers.blank?}
          @import_trackers = []
          @import_custom_fields = []
          @import_templates = ImportTemplate.where(:user_id => User.current.id)
        end

        def verify_file_extension(filename)
          File.extname(filename)
        end

        def xlsx
          @import.settings.merge!(
            'file_type' => "xlsx",
            'project_id' => params[:project_id],
            'tracker_id' => params[:tracker_id],
            'current_user' => User.current,
            'custom_fields' => params[:selected_columns]
          )

          if params[:save_template] == "1";

            if params["import_template_id"].nil?
              @import_templates = []
            else
              @import_templates = ImportTemplate.where(:user_id => User.current.id, :id => params["import_template_id"]).first
            end

            unless @import_templates.blank?
              template = @import_templates
              template.settings = @import.settings
              template.save!
            else
              import_template = ImportTemplate.new
              import_template.user = User.current
              import_template.name = "#{Project.find(params[:project_id]).name} - #{Tracker.find(params[:tracker_id]).name}"
              import_template.settings = @import.settings
              import_template.save!
            end
          end
          @import.save!
          redirect_to import_run_path(@import)
        end

        def save_file(import)
          @attachment = Attachment.new(:file => File.open(import.filepath))

          @attachment.author = User.current
          @attachment.filename = Redmine::Utils.random_hex(16)
          @attachment.content_type = params[:file].content_type
          @attachment.save!

          @import.settings.merge!(
            'diskfile' => @attachment.diskfile
          )
          @import.save!
        end
      end
    end
  end
end
