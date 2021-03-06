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
            post group_signups_path, params: { group_signup: FactoryBot.attributes_for(:group_signup, years_as_gc: 3) }
        end
    end

    assert_response :redirect
    assert_match /Thank you for registering/, flash[:notice]
  end

  test "should update an existing group on group signup" do
    group = FactoryBot.create(:group, status: "Stale")

    assert_no_difference('Group.count') do
        assert_difference('User.count', 2) do
            post group_signups_path, params: { group_signup: FactoryBot.attributes_for(:group_signup, name: group.name) }
        end
    end

    assert_response :redirect
    assert_match /Thank you for registering/, flash[:notice]
  end

  test "should update an existing group on group signup by selection" do
    group = FactoryBot.create(:group, status: "Stale")

    assert_no_difference('Group.count') do
        assert_difference('User.count', 2) do
            post group_signups_path, params: { group_signup: FactoryBot.attributes_for(:group_signup, id: group.id) }
        end
    end

    assert_response :redirect
    assert_match /Thank you for registering/, flash[:notice]
  end

  test "should not update an existing group that has already registered" do
    group = FactoryBot.create(:group, status: "Submitted")

    assert_no_difference('Group.count') do
        assert_no_difference('User.count') do
            post group_signups_path, params: { group_signup: FactoryBot.attributes_for(:group_signup, name: group.name) }
        end
    end

    assert_response :success
    assert_match /There was a problem/, flash[:notice]
  end

  test "should not create a group signup with same church rep and gc" do
    assert_no_difference('Group.count') do
        assert_no_difference('User.count') do
            post group_signups_path, params: { group_signup: FactoryBot.attributes_for(:group_signup, gc_email: "a@abc.com", church_rep_email: "a@abc.com") }
        end
    end

    assert_response :success
    assert_match /There was a problem/, flash[:notice]
  end

  test "should not create a group signup with errors on group" do
    assert_no_difference('Group.count') do
        assert_no_difference('User.count') do
            post group_signups_path, params: { group_signup: FactoryBot.attributes_for(:group_signup, email: "A") }
        end
    end

    assert_response :success
    assert_match /There was a problem/, flash[:notice]
  end

  test "should not create a group signup with errors on church_rep" do
    assert_no_difference('Group.count') do
        assert_no_difference('User.count') do
            post group_signups_path, params: { group_signup: FactoryBot.attributes_for(:group_signup, church_rep_email: "A") }
        end
    end

    assert_response :success
    assert_match /There was a problem/, flash[:notice]
  end

  test "should not create a group signup with errors on gc" do
    assert_no_difference('Group.count') do
        assert_no_difference('User.count') do
            post group_signups_path, params: { group_signup: FactoryBot.attributes_for(:group_signup, gc_email: "A") }
        end
    end

    assert_response :success
    assert_match /There was a problem/, flash[:notice]
  end
end
