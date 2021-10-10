require 'simplecov'
SimpleCov.start

ENV['RAILS_ENV'] ||= 'test'
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end

module Devise::Test::IntegrationHelpers
  def sign_in(user)
    post new_user_session_url, params: { user: {email: user.email, password: user.password} }
    assert_response :redirect
  end
end

module RemoveUploadedFiles
  def after_teardown
    super
    remove_uploaded_files
  end

private

  def remove_uploaded_files
    FileUtils.rm_rf(Rails.root.join('tmp', 'storage'))
  end
end

module ActionDispatch
  class IntegrationTest
    prepend RemoveUploadedFiles
  end
end
