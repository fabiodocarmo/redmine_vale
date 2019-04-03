class AtribuicaoAutomaticasController < CrujCrujCrujController
  unloadable
  before_filter :require_admin

  def index_attributes
    [
      :project,
      :tracker,
      :group,
      :status_from,
      :status_to,
      [:redistribute, AtribuicaoAutomatica::REDISTRIBUTE_TYPE],
      :use_custom_field,
      :custom_field,
      :custom_field_value
    ]
  end

  def form_fields
    [
      { field_name: :project                  , data_validation: {validation: {clazz: Project    , field: :name          }, allow_blank: true}  },
      { field_name: :all_projects             , data_validation: {validation: ["true", "false"]                           , allow_blank: false} },
      { field_name: :tracker                  , data_validation: {validation: {clazz: Tracker    , field: :name          }, allow_blank: true}  },
      { field_name: :all_trackers             , data_validation: {validation: ["true", "false"]                           , allow_blank: false} },
      { field_name: :group                    , data_validation: {validation: {clazz: Group      , field: :lastname      }, allow_blank: false} },
      { field_name: :weekend_group            , data_validation: {validation: {clazz: Group      , field: :lastname      }, allow_blank: true}  },
      { field_name: :status_from              , data_validation: {validation: {clazz: IssueStatus, field: :name          }, allow_blank: true}  },
      { field_name: :all_status_from          , data_validation: {validation: ["true", "false"]                           , allow_blank: false} },
      { field_name: :status_to                , data_validation: {validation: {clazz: IssueStatus, field: :name          }, allow_blank: false} },
      { field_name: :redistribute             , data_validation: {validation: AtribuicaoAutomatica::REDISTRIBUTE_TYPE.keys, allow_blank: true}  },
      { field_name: :use_custom_field         , data_validation: {validation: ["true", "false"]                           , allow_blank: false} },
      { field_name: :custom_field             , data_validation: {validation: {clazz: IssueCustomField, field: :name     }, allow_blank: true}  },
      { field_name: :custom_field_value       , data_validation: {validation: nil                                         , allow_blank: true}  },
      { field_name: :second_custom_field      , data_validation: {validation: {clazz: IssueCustomField, field: :name     }, allow_blank: true}  },
      { field_name: :second_custom_field_value, data_validation: {validation: nil                                         , allow_blank: true}  },
      { field_name: :user_custom_field        , data_validation: {validation: {clazz: UserCustomField, field: :name      }, allow_blank: true}  },
      { field_name: :issue_user_custom_field  , data_validation: {validation: {clazz: IssueCustomField, field: :name     }, allow_blank: true}  },
    ]
  end

  protected

  def filter_for_second_custom_field
    "second_custom_field_name_cont"
  end

  def filter_for_weekend_group
    "weekend_group_lastname_cont"
  end
end
