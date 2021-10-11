require "test_helper"

class RolesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    
    sign_in @user
  end

  test "should show available roles" do
    get available_roles_roles_url

    assert_response :success
  end

  test "should switch roles" do
    role = FactoryBot.create(:role, name: 'participant')

    patch switch_role_url(role)

    assert_redirected_to home_gc_info_url
  end
end 
