require "test_helper"

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    FactoryBot.create(:group)
  end

  test "admin user should land on admin welcome page" do
    sign_in @user

    assert_redirected_to root_url
    follow_redirect!
    assert_redirected_to admin_sports_url
  end

  test "gc user should land on group info page" do
    gc_user = FactoryBot.create(:user, :gc)
    sign_in gc_user

    assert_redirected_to root_url
    follow_redirect!
    assert_redirected_to home_gc_info_url
  end

  test "church_rep user should land on group info page" do
    church_rep_user = FactoryBot.create(:user, :church_rep)
    sign_in church_rep_user

    assert_redirected_to root_url
    follow_redirect!
    assert_redirected_to home_gc_info_url
  end

  test "participant user should land on group info page" do
    participant_user = FactoryBot.create(:user, :participant)
    sign_in participant_user

    assert_redirected_to root_url
    follow_redirect!
    assert_redirected_to home_gc_info_url
  end
end
