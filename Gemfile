source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 8.1.0'
# Use postgresql as the database for Active Record
gem 'pg', '1.4.1'
# Use Puma as the app server
gem 'puma', ">= 5.0"
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0.1'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'csv'
# gem 'importmap-rails'
# gem 'hotwire-rails'

# Use Active Storage variant
gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

# SYG Application gems, not included by default with Rails
gem 'delayed_job_active_record'
gem 'daemons'
gem 'simple_form'
gem 'devise'
gem 'exception_handler', '~> 0.8.0.0'
gem 'cancancan'
gem 'activemodel-serializers-xml'
gem 'aws-sdk-s3', require: false
# gem 'gmaps4rails'
gem 'will_paginate'
gem 'will_paginate-bootstrap-style'
gem 'chartkick'
# gem 'coffee-rails'
# gem 'jquery-rails'
gem 'prawn-rails'
gem 'caxlsx'
gem 'caxlsx_rails'
gem 'roo', "~> 2.10.0"

group :production do
  gem 'newrelic_rpm'
  gem 'lograge'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
  gem 'mocha'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler' 
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'annotaterb'
  gem 'brakeman'
  gem 'foreman'
  gem 'letter_opener'
end

# Adds support for Capybara system testing and selenium driver
# including outside :test group due to deploy issues to Heroku
gem 'capybara', '>= 3.26'

group :test do
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
  gem 'simplecov', require: false
  # Minitest 6 has breaking changes
  gem 'minitest', '~> 5'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[ windows jruby ]
