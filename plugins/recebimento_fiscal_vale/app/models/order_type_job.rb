class OrderTypeJob < ExecJob
  unloadable

  include HTTParty

  base_uri Setting.plugin_recebimento_fiscal_vale['base_url']

  def perform(issue)
    issue = issue.is_a?(Issue) ? issue : Issue.find(issue)
    order_type = OrderTypeResource.order_type(issue)
    issue.custom_field_values =
      { Setting.plugin_recebimento_fiscal_vale['order_type']['field'] => order_type }
  end
end
