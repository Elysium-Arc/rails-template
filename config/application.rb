require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Pulsar
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Autoload providers from app/lib
    config.autoload_paths += %W[#{config.root}/app/lib]
    config.eager_load_paths += %W[#{config.root}/app/lib]

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "UTC"
  # I18n configuration
  config.i18n.default_locale = :en
  config.i18n.available_locales = %i[en fr ar]
    # config.eager_load_paths << Rails.root.join("extras")

    config.generators do |g|
      g.test_framework :rspec,
                      fixtures: true,
                      view_specs: false,
                      helper_specs: false,
                      routing_specs: false,
                      controller_specs: true,
                      request_specs: true
    end
  end
end
