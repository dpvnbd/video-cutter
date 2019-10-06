require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module VideoCutter
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    config.active_storage.analyzers = []
    config.active_storage.previewers = []

    api_host = ENV['API_HOST'] || "http://localhost:3000"
    config.action_mailer.default_url_options = {host: api_host}
    Rails.application.routes.default_url_options[:host] = api_host
  end
end

if ENV['RAILS_ENV'] != 'production'
  RSpec.configure do |config|
    config.swagger_dry_run = false
  end
end

if ENV['DOCKER_LOGS']
  fd = IO.sysopen("/proc/1/fd/1", "w")
  io = IO.new(fd, "w")
  io.sync = true
  MY_APPLICATION_LOG_OUTPUT = io
else
  MY_APPLICATION_LOG_OUTPUT = $stdout
end