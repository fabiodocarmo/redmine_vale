class ExecJobsController < CrujCrujCrujController
  unloadable
  before_filter :require_admin

  def index_attributes
    [
      :type,
      :run_sync,
      :project,
      :tracker,
      :status_from,
      :status_to
    ]
  end

  def form_fields
    [
      { field_name: :project                  , data_validation: {validation: {clazz: Project    , field: :name          }, allow_blank: true}  },
      { field_name: :all_projects             , data_validation: {validation: ["true", "false"]                           , allow_blank: false} },
      { field_name: :tracker                  , data_validation: {validation: {clazz: Tracker    , field: :name          }, allow_blank: true}  },
      { field_name: :all_trackers             , data_validation: {validation: ["true", "false"]                           , allow_blank: false} },
      { field_name: :status_from              , data_validation: {validation: {clazz: IssueStatus, field: :name          }, allow_blank: true}  },
      { field_name: :all_status_from          , data_validation: {validation: ["true", "false"]                           , allow_blank: false} },
      { field_name: :status_to                , data_validation: {validation: {clazz: IssueStatus, field: :name          }, allow_blank: false} },
      { field_name: :command                  , data_validation: {validation: nil                                         , allow_blank: false}  },
      { field_name: :type                     , data_validation: {validation: ExecJob.jobs.map(&:name)                    , allow_blank: false} },
    ]
  end

  # TODO: Send this logic to cruj_cruj_cruj
  def update
    if @resource.update_attributes(safe_parameters)
      redirect_to(action: :index, notice: l("#{snake_case_model_name}_edit_success_message"))
    else
      render action: 'edit'
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def safe_parameters
    params.require(snake_case_model_name).permit!
  end

  def model_name
    if @resource
      @resource.class.name
    else
      self.class.name.sub(/Controller$/, '').singularize
    end
  end
end
