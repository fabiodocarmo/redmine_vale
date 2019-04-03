class AutoIssuesController < CrujCrujCrujController
  unloadable

  before_filter :require_admin

  def index_attributes
    [
      :project,
      :tracker,
      :issue_status,
      :title,
      :principal,
      :type
    ]
  end

  def show
    @auto_issue = auto_issue_class.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def form
    @auto_issue = auto_issue_class.where(id: params[:id]).first_or_initialize
    @auto_issue.attributes = @auto_issue_params
  end

  def new
    @auto_issue = auto_issue_class.new
  end

  def create
    auto_issue_params = params[trigger_type.underscore]
    auto_issue_params[:watcher_ids] = auto_issue_params[:watcher_ids].reject(&:empty?).map(&:to_i) if auto_issue_params[:watcher_ids]

    @auto_issue = auto_issue_class.new(auto_issue_params)
    respond_to do |format|
      if @auto_issue.save
        format.html do
          redirect_to( auto_issues_path, notice: t('auto_issue.create_success'))
        end
        format.xml  { head :ok }
      else
        format.html { render action: 'new' }
        format.xml  do
          render xml: @auto_issue.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def edit
    @auto_issue = auto_issue_class.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def update
    @auto_issue = auto_issue_class.find(params[:id])

    respond_to do |format|
      auto_issue_params = params[trigger_type.underscore]

      auto_issue_params[:watcher_ids] = auto_issue_params[:watcher_ids].reject(&:empty?).map(&:to_i) if auto_issue_params[:watcher_ids]

      if @auto_issue.update_attributes(auto_issue_params)
        format.html do
          redirect_to(auto_issues_path, notice: t('auto_issue.update_success'))
        end
        format.xml  { head :ok }
      else
        format.html { render action: 'edit' }
        format.xml  do
          render xml: @auto_issue.errors, status: :unprocessable_entity
        end
      end
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def destroy
    @auto_issue = auto_issue_class.find(params[:id])
    @auto_issue.destroy
    respond_to do |format|
      format.html { redirect_to(auto_issues_url) }
      format.xml  { head :ok }
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  private

  def trigger_type
    @auto_issue_params = AutoIssue.trigger_types.map(&:underscore).map { |t| params[t.to_sym] }.reduce(false) { |acc, v| acc || v }
    @type = (@auto_issue_params && @auto_issue_params[:type]) || params[:type]
    @trigger_type ||= AutoIssue.trigger_types.include?(@type) ? @type : "ScheduleAutoIssue"
  end

  def auto_issue_class
    @auto_issue_class ||= trigger_type.constantize
  end
end
