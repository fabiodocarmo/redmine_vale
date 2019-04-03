class AutoChangeStatusesController < CrujCrujCrujController
  unloadable
  before_filter :require_admin

  def index_attributes
    [
      :project,
      :tracker,
      :role,
      :status_from,
      :status_to,
      [:action, AutoChangeStatus::ACTIONS],
      :use_custom_field,
      :custom_field,
      :custom_field_value
    ]
  end

  def form_fields
    [
      { field_name: :project    , data_validation: {validation: {clazz: Project    , field: :name                   }, allow_blank: true}  },
      { field_name: :all_projects             , data_validation: {validation: ["true", "false"]                      , allow_blank: false} },
      { field_name: :tracker    , data_validation: {validation: {clazz: Tracker    , field: :name                   }, allow_blank: true}  },
      { field_name: :all_trackers             , data_validation: {validation: ["true", "false"]                      , allow_blank: false} },
      { field_name: :role       , data_validation: {validation: {clazz: Role       , field: :name                   }, allow_blank: true}  },
      { field_name: :all_roles                , data_validation: {validation: ["true", "false"]                      , allow_blank: false} },
      { field_name: :status_from, data_validation: {validation: {clazz: IssueStatus, field: :name                   }, allow_blank: true}  },
      { field_name: :all_status_from          , data_validation: {validation: ["true", "false"]                      , allow_blank: false} },
      { field_name: :status_to  , data_validation: {validation: {clazz: IssueStatus, field: :name                   }, allow_blank: false} },
      { field_name: :use_custom_field         , data_validation: {validation: ["true", "false"]                      , allow_blank: false} },
      { field_name: :custom_field             , data_validation: {validation: {clazz: IssueCustomField, field: :name}, allow_blank: true}  },
      { field_name: :custom_field_value       , data_validation: {validation: nil                                    , allow_blank: true}  },
      { field_name: :action     , data_validation: {validation: AutoChangeStatus::ACTIONS.keys                       , allow_blank: false} },
    ]
  end
end
