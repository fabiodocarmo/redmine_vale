class BlockDuplicatesController < ApplicationController
  unloadable
  before_filter :require_admin

  def index
    @block_duplicates = BlockDuplicate.all
  end

  def show
    @block_duplicate = BlockDuplicate.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def new
    @block_duplicate = BlockDuplicate.new
  end

  def edit
    @block_duplicate = BlockDuplicate.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def update
    @block_duplicate = BlockDuplicate.find(params[:id])
    respond_to do |format|
      if @block_duplicate.update_attributes(params[:block_duplicate])
        format.html do
          redirect_to(@block_duplicate, notice: l(:block_duplicate_rule_edit_sucess_message))
        end
        format.xml  { head :ok }
      else
        format.html { render action: 'edit' }
        format.xml  do
          render xml: @block_duplicate.errors, status: :unprocessable_entity
        end
      end
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def create
    @block_duplicate = BlockDuplicate.new(params[:block_duplicate])
    respond_to do |format|
      if @block_duplicate.save
        format.html do
          redirect_to(@block_duplicate, notice: l(:block_duplicate_rule_create_sucess_message))
        end
        format.xml  { head :ok }
      else
        format.html { render action: 'new' }
        format.xml  do
          render xml: @block_duplicate.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @block_duplicate = BlockDuplicate.find(params[:id])
    @block_duplicate.destroy
    respond_to do |format|
      format.html { redirect_to(block_duplicates_url) }
      format.xml  { head :ok }
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
