require 'rails/generators/base'

class WidgetGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :plugin_name, type: :string
  argument :widget_id, type: :string
  argument :template_name, type: :string, default: 'text'

  def generate_widget
    template "#{template_name.underscore}/stylesheet.css.erb", "plugins/#{plugin_name.underscore}/assets/stylesheets/widgets/#{widget_id.underscore}.css"
    template "#{template_name.underscore}/javascript.js.erb", "plugins/#{plugin_name.underscore}/assets/javascripts/widgets/#{widget_id.underscore}.js"
    template "#{template_name.underscore}/content.html.erb", "plugins/#{plugin_name.underscore}/app/views/widgets/_#{widget_id.underscore}.html.erb"
  end
end
