require "test_helper"

class Admin::AwardsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @award = FactoryBot.create(:award)
    
    sign_in @user
end

  test "should get new good sports" do
    get new_good_sports_admin_awards_url

    assert_response :success
  end

  test "should get new spirit" do
    get new_spirit_admin_awards_url

    assert_response :success
  end

  test "should get new volunteer" do
    get new_volunteer_admin_awards_url

    assert_response :success
  end

  test "should create good sports award" do
    assert_difference('Award.count') do
      post create_good_sports_admin_awards_path, params: { award: FactoryBot.attributes_for(:award) }
    end

    assert_response :redirect
    assert_match /Thanks for your nomination/, flash[:notice]
  end

  test "should create spirit award" do
    assert_difference('Award.count') do
      post create_spirit_admin_awards_path, params: { award: FactoryBot.attributes_for(:award) }
    end

    assert_response :redirect
    assert_match /Thanks for your nomination/, flash[:notice]
  end

  test "should create volunteer award" do
    assert_difference('Award.count') do
      post create_volunteer_admin_awards_path, params: { award: FactoryBot.attributes_for(:award) }
    end

    assert_response :redirect
    assert_match /Thanks for your nomination/, flash[:notice]
  end
end
