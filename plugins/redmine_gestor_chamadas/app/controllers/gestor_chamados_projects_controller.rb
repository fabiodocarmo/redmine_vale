class GestorChamadosProjectsController < ApplicationController
  unloadable

  layout 'gestor_chamados'

  helper :sort
  include SortHelper
  helper :custom_fields
  include CustomFieldsHelper
  helper :issues
  helper :queries
  include QueriesHelper
  helper :repositories
  include RepositoriesHelper
  include ProjectsHelper
  helper :members

  def index
    @project = Project.find(Setting.plugin_redmine_gestor_chamadas[:wiki_project])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  protected

  def check_if_login_required
    false
  end

end
