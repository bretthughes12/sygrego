require_relative "boot"

raw_config = File.read(File.expand_path("../app_config.yml", __FILE__))  

require "rails/all"

APP_CONFIG = YAML.load(raw_config)[Rails.env].symbolize_keys

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Sygrego
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Melbourne"
    # config.eager_load_paths << Rails.root.join("extras")
    config.active_support.remove_deprecated_time_with_zone_name = true
    
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
