require_relative "boot"

raw_config = File.read(File.expand_path("../app_config.yml", __FILE__))  

require "rails/all"

begin
  APP_CONFIG = YAML.load(raw_config, aliases: true)[Rails.env].symbolize_keys
rescue ArgumentError
  APP_CONFIG = YAML.load(raw_config)[Rails.env].symbolize_keys
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Sygrego
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Melbourne"
    # config.eager_load_paths << Rails.root.join("extras")

    # Devise config
    config.to_prepare do
      # Configure single controller layout
      Devise::SessionsController.layout "users"
      Devise::RegistrationsController.layout "users"
      Devise::PasswordsController.layout "users"
    
      # Or to configure mailer layout
      Devise::Mailer.layout "mailer" 
    end
    
#    config.active_job.queue_adapter = :delayed_job

    # Exception Handler config hash (no initializer required)
    config.exception_handler = {
      dev:        false,
      email:      "ticket@stateyouthgames.com",

      # On default 5xx error page, social media links included
      # social: {        
      #  facebook: 'sygvic',    
      #  twitter:  'sygvic'  
      # },  

      # All keys interpolated as strings, so you can use symbols, strings or integers where necessary
      exceptions: {
        '422' => {
          layout: "exception", # define layout
          notification: true  # (false by default)
        },    
        '4xx' => {
          layout: "exception", # define layout
          notification: false  # (false by default)
        },    
        '5xx' => {
          layout: "exception", # define layout
          notification: true   # (false by default)
        }
      }
    }
  end
end
