Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false

  # Disable delivery errors
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to stderr and the Rails logger.
  config.active_support.deprecation = [:stderr, :log]

  config.active_job.queue_adapter = :delayed_job

  config.action_mailer.smtp_settings = {
      :address => 'localhost',
      :port => '1025'
  }
end
