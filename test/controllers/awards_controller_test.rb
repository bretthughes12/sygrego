require "test_helper"

class AwardsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
  end

  test "should get new good sports" do
    get new_good_sports_awards_url

    assert_response :success
  end

  test "should get new spirit" do
    get new_spirit_awards_url

    assert_response :success
  end

  test "should get new volunteer" do
    get new_volunteer_awards_url

    assert_response :success
  end

  test "should create good sports award" do
    assert_difference('Award.count') do
      post create_good_sports_awards_path, params: { award: FactoryBot.attributes_for(:award) }
    end

    assert_response :redirect
    assert_match /Thanks for your nomination/, flash[:notice]
  end

  test "should not create good sports award with errors" do
    assert_no_difference('Award.count') do
      post create_good_sports_awards_path, params: { award: FactoryBot.attributes_for(:award, description: nil) }
    end

    assert_response :success
  end

  test "should create spirit award" do
    assert_difference('Award.count') do
      post create_spirit_awards_path, params: { award: FactoryBot.attributes_for(:award) }
    end

    assert_response :redirect
    assert_match /Thanks for your nomination/, flash[:notice]
  end

  test "should not create spirit award with errors" do
    assert_no_difference('Award.count') do
      post create_spirit_awards_path, params: { award: FactoryBot.attributes_for(:award, description: nil) }
    end

    assert_response :success
  end

  test "should create volunteer award" do
    assert_difference('Award.count') do
      post create_volunteer_awards_path, params: { award: FactoryBot.attributes_for(:award) }
    end

    assert_response :redirect
    assert_match /Thanks for your nomination/, flash[:notice]
  end

  test "should not create volunteer award with errors" do
    assert_no_difference('Award.count') do
      post create_volunteer_awards_path, params: { award: FactoryBot.attributes_for(:award, description: nil) }
    end

    assert_response :success
  end
end
