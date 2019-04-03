class RulesController < CrujCrujCrujController
  unloadable

  before_filter :require_admin

  def index_attributes
    [
      :min_sent,
      :max_sent,
      :area,
      :hierarchy,
      :classification,
      :email_template
    ]
  end

  def form_fields
    [
      { field_name: :min_sent, data_validation: {validation: nil, allow_blank: true}  },
      { field_name: :max_sent, data_validation: {validation: nil, allow_blank: true}  },
      { field_name: :area, data_validation: {validation: nil, allow_blank: true}  },
      { field_name: :hierarchy, data_validation: {validation: nil, allow_blank: true}  },
      { field_name: :classification, data_validation: {validation: nil, allow_blank: true}  },
      { field_name: :email_template, data_validation: {validation:{clazz: EmailTemplate, field: :name}, allow_blank: true}  }
    ]
  end

  def exclude_index_filter_attributes
    %w(^id$ _id created_at updated_at min_sent max_sent)
  end

  def filter_for_email_template
    "email_template_name_cont"
  end

  def export_template
    @q = model_class.ransack(params[:q])
    @q.sorts = default_sort if @q.sorts.blank?

    filename = CrujCrujCruj::Services::ImportRules.export_template(form_fields, @q.result)
    send_file(filename, filename: "PainelRegras.xlsx", type: "application/vnd.ms-excel")
  end

end
