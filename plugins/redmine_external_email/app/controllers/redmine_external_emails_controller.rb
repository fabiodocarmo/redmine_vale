class RedmineExternalEmailsController < CrujCrujCrujController
  unloadable
  before_filter :require_admin

  def index_attributes
    [
      :project,
      :tracker,
      :status_from,
      :status_to,
      :subject
    ]
  end

  def form_fields
    [
      { field_name: :project           , data_validation: {validation: {clazz: Project    , field: :name     }, allow_blank: true}  },
      { field_name: :all_projects      , data_validation: {validation: ["true", "false"]                      , allow_blank: false} },
      { field_name: :tracker           , data_validation: {validation: {clazz: Tracker    , field: :name     }, allow_blank: true}  },
      { field_name: :all_trackers      , data_validation: {validation: ["true", "false"]                      , allow_blank: false} },
      { field_name: :status_from       , data_validation: {validation: {clazz: IssueStatus, field: :name     }, allow_blank: true}  },
      { field_name: :all_status_from   , data_validation: {validation: ["true", "false"]                      , allow_blank: false} },
      { field_name: :status_to         , data_validation: {validation: {clazz: IssueStatus, field: :name     }, allow_blank: false} },
      { field_name: :email_custom_field, data_validation: {validation: {clazz: IssueCustomField, field: :name}, allow_blank: true}  },
      { field_name: :subject           , data_validation: {validation: nil                                    , allow_blank: true}  },
      { field_name: :body              , data_validation: {validation: nil                                    , allow_blank: true}  },
      { field_name: :send_attachments  , data_validation: {validation: ["true", "false"]                      , allow_blank: false} },
    ]
  end
end
