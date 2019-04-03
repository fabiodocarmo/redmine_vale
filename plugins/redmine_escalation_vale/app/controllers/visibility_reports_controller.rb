class VisibilityReportsController < CrujCrujCrujController
  unloadable

  before_filter :require_admin

  def index_attributes
    [
      :issue,
      :tracker,
      :area,
      :classification,
      :user,
      :supplier_social_name,
      :supplier_cnpj,
      :phase_aging,
      :sent_number
    ]
  end

  def form_fields
    [
      { field_name: :classification, data_validation: {validation: nil, allow_blank: true}  },
      { field_name: :tracker, data_validation: {validation: {clazz: Tracker, field: :name}, allow_blank: true}  },
      { field_name: :supplier_social_name, data_validation: {validation: nil, allow_blank: true}  },
      { field_name: :supplier_cnpj, data_validation: {validation: nil, allow_blank: true}  },
      { field_name: :area, data_validation: {validation: nil, allow_blank: true}  },
      { field_name: :user, data_validation: {validation: {clazz: UserCustomField, field: :name}, allow_blank: true}  },
      { field_name: :phase_aging, data_validation: {validation: nil, allow_blank: true}  },
      { field_name: :sent_number, data_validation:{validation: nil, allow_blank: true}  }
    ]
  end

  def exclude_index_filter_attributes
    %w(^id$ _id created_at updated_at total_aging phase_aging sent_number issue)
  end

  def export_template
    params[:q] = {}
    if params[:filter].present?
      filter_param = []
      if (params[:filter].include? ",")
        filter_param = params[:filter].split(",").reject{|r|  !r.present?}
      else
        filter_param << params[:filter]
      end
      @q = model_class.ransack(params[:q].merge({issue_id_in: filter_param}))
    else
      @q = model_class.ransack(params[:q])
    end

    @q.sorts = default_sort if @q.sorts.blank?

    filename = CrujCrujCruj::Services::ImportRules.export_template(form_fields, @q.result)
    send_file(filename, filename: "ChamadosPendentes.xlsx", type: "application/vnd.ms-excel")
  end

  def filter_for_user
    "user_firstname_or_user_lastname_cont"
  end

  def filter_for_issue
    "issue_id_eq"
  end

  def find_all_resources
    super
    params[:q] = {}
    if params[:filter].present?
      filter_param = []
      if (params[:filter].include? ",")
        filter_param = params[:filter].split(",").reject{|r|  !r.present?}
      else
        filter_param << params[:filter]
      end
      @resources = model_class.ransack(params[:q].merge({issue_id_in: filter_param})).result.page(params[:page])
    end
  end

end
