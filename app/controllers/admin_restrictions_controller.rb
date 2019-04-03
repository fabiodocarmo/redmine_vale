class AdminRestrictionsController < ApplicationController
  layout 'admin'
  before_filter :require_admin
  before_filter :require_manage_restriction_permition

  require_sudo_mode :create, :update, :destroy

  def index
    @admin_restrictions = AdminRestriction.all
  end

  def show
    @admin_restriction = AdminRestriction.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def new
    @admin_restriction = AdminRestriction.new
  end

  def create
    @admin_restriction = AdminRestriction.new(params[:admin_restriction])
    respond_to do |format|
      if @admin_restriction.save
        format.html do
          redirect_to(@admin_restriction, notice: t('admin_restriction.create_success'))
        end
        format.xml  { head :ok }
      else
        format.html { render action: 'new' }
        format.xml  do
          render xml: @admin_restriction.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def edit
    @admin_restriction = AdminRestriction.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def update
    @admin_restriction = AdminRestriction.find(params[:id])
    respond_to do |format|
      if @admin_restriction.update_attributes(params[:admin_restriction])
        format.html do
          redirect_to(@admin_restriction, notice: t('admin_restriction.update_success'))
        end
        format.xml  { head :ok }
      else
        format.html { render action: 'edit' }
        format.xml  do
          render xml: @admin_restriction.errors, status: :unprocessable_entity
        end
      end
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def destroy
    @admin_restriction = AdminRestriction.find(params[:id])
    @admin_restriction.destroy
    respond_to do |format|
      format.html { redirect_to(admin_restrictions_url) }
      format.xml  { head :ok }
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def require_manage_restriction_permition
    return unless require_login
    if !User.current.admin? || !User.current.admin_can?(:manage_admin_restriction)
      render_403
      return false
    end
    true
  end
end
