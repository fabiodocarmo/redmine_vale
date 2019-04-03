class ApprovalsController < CrujCrujCrujController
  unloadable
  before_filter :require_admin

  def index_attributes
    [
      :project,
      :tracker,
      :group,
      :custom_field,
      [:sign, Approval::SIGNS],
      :value,
      :level,
      :level_below
    ]
  end

  def form_fields
    [
      { field_name: :project     , data_validation: {validation: {clazz: Project    , field: :name          }, allow_blank: false} },
      { field_name: :tracker     , data_validation: {validation: {clazz: Tracker    , field: :name          }, allow_blank: false} },
      { field_name: :status_from , data_validation: {validation: {clazz: IssueStatus, field: :name          }, allow_blank: true}  },
      { field_name: :status_to   , data_validation: {validation: {clazz: IssueStatus, field: :name          }, allow_blank: false} },
      { field_name: :group       , data_validation: {validation: {clazz: Group      , field: :lastname      }, allow_blank: false} },
      { field_name: :custom_field, data_validation: {validation: {clazz: IssueCustomField, field: :name     }, allow_blank: true}  },
      { field_name: :sign        , data_validation: {validation: Approval::SIGNS.keys.map(&:to_s)            , allow_blank: true}  },
      { field_name: :value       , data_validation: {validation: nil                                         , allow_blank: true}  },
      { field_name: :level       , data_validation: {validation: nil                                         , allow_blank: false}  },
      { field_name: :level_below , data_validation: {validation: nil                                         , allow_blank: false}  },

      { field_name: :use_second_custom_field  , data_validation: {validation: ["true", "false"]                           , allow_blank: false} },
      { field_name: :second_custom_field      , data_validation: {validation: {clazz: IssueCustomField, field: :name     }, allow_blank: true}  },
      { field_name: :second_custom_field_value, data_validation: {validation: nil                                         , allow_blank: true}  },
    ]
  end
end
