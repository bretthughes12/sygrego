require "test_helper"

class Admin::TasksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    FactoryBot.create(:audit_trail)
    @user = FactoryBot.create(:user, :admin)
    
    sign_in @user
  end

  test "should get sports draws" do
    get sports_draws_admin_tasks_url

    assert_response :success
  end
end
