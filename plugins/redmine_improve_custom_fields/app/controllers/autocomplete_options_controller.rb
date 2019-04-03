class AutocompleteOptionsController < ApplicationController
  unloadable

  skip_before_filter :check_if_login_required

  def index
    q = params[:query]
    cf = params[:custom_field_id]
    render json: { data: Improvecf::AutocompleteOption.filter(cf, q).limit(20).pluck(:value),
                  total: Improvecf::AutocompleteOption.filter(cf, q).count }
  end

end
