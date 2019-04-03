class HierarchiesController < CrujCrujCrujController
  unloadable

  before_filter :require_admin

  def index_attributes
    [
      :user,
      :n2,
      :n3,
      :n4
    ]
  end

  def form_fields
    [
      { field_name: :user, data_validation: {validation: {clazz: UserCustomField, field: :name}, allow_blank: true}  },
      { field_name: :n2, data_validation: {validation: {clazz: UserCustomField, field: :name}, allow_blank: true}  },
      { field_name: :n3, data_validation: {validation: {clazz: UserCustomField, field: :name}, allow_blank: true}  },
      { field_name: :n4, data_validation: {validation: {clazz: UserCustomField, field: :name}, allow_blank: true}  }
    ]
  end

  def exclude_index_filter_attributes
    %w(^id$ _id created_at updated_at n1 n2 n3 n4)
  end

  def filter_for_user
    "user_firstname_or_user_lastname_cont"
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
      @q = model_class.ransack(params[:q].merge({user_id_in: filter_param}))
    else
      @q = model_class.ransack(params[:q])
    end

    @q.sorts = default_sort if @q.sorts.blank?

    filename = CrujCrujCruj::Services::ImportRules.export_template(form_fields, @q.result)
    send_file(filename, filename: "Hierarquia.xlsx", type: "application/vnd.ms-excel")
  end

  def find_all_resources
    super
    params[:q] = {}
    if params[:filter].present?
      filter_param = params[:filter].reject{|r|  !r.present?}
      @resources = model_class.ransack(params[:q].merge({user_id_in: filter_param})).result.page(params[:page])
    end
  end

end
