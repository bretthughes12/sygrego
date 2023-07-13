require "test_helper"

class Sc::InfoControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :sc)

    sign_in @user
  end

  test "should get home page" do
    get home_sc_info_url

    assert_response :success
  end

  test "should get other home page when not sc" do
    sign_out @user
    admin_user = FactoryBot.create(:user, :admin)
    sign_in admin_user

    get home_sc_info_url

    assert_redirected_to home_admin_info_url
  end

  test "should get sign in page when sc not signed in" do
    sign_out @user

    get home_sc_info_url

    assert_redirected_to new_user_session_url
  end
end
