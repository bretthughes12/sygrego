require "test_helper"

class GroupSignupsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    FactoryBot.create(:role, name: 'admin')
    FactoryBot.create(:role, name: 'gc', group_related: true)
    FactoryBot.create(:role, name: 'church_rep', group_related: true)
    FactoryBot.create(:user)
  end

  test "should get new" do
    get new_group_signup_url

    assert_response :success
  end

  test "should create group signup" do
    assert_difference('Group.count') do
        assert_difference('User.count', 2) do
            post group_signups_path, params: { group_signup: FactoryBot.attributes_for(:group_signup) }
        end
    end

    assert_redirected_to home_gc_info_url
    assert_match /Thank you for registering/, flash[:notice]
  end

  test "should not create a group signup with errors" do
    assert_no_difference('Group.count') do
        assert_no_difference('User.count') do
            post group_signups_path, params: { group_signup: FactoryBot.attributes_for(:group_signup, gc_email: "A") }
        end
    end

    assert_response :success
    assert_match /There was a problem/, flash[:notice]
  end
end
