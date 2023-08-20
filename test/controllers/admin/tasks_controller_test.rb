require "test_helper"

class Admin::TasksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    @setting = FactoryBot.create(:setting)
    FactoryBot.create(:audit_trail)
    @user = FactoryBot.create(:user, :admin)
    
    sign_in @user
  end

  test "should get sports draws" do
    get sports_draws_admin_tasks_url

    assert_response :success
  end

  test "should allocate restricted sports" do
    post allocate_restricted_admin_tasks_url

    assert_redirected_to summary_admin_ballot_results_path
    assert_match /allocation is under way/, flash[:notice]

    @setting.reload
    assert_equal true, @setting.restricted_sports_allocated
  end

  test "should not allocate restricted sports when already done" do
    @setting.restricted_sports_allocated = true
    @setting.save

    post allocate_restricted_admin_tasks_url

    assert_redirected_to summary_admin_ballot_results_path
    assert_match /already allocated/, flash[:notice]
  end

  test "should finalise team sports" do
    post finalise_team_sports_admin_tasks_url

    assert_redirected_to sports_draws_admin_tasks_path
    assert_match /team grades is under way/, flash[:notice]

    @setting.reload
    assert_equal true, @setting.team_draws_complete
  end

  test "should not finalise team sports when already done" do
    @setting.team_draws_complete = true
    @setting.save

    post finalise_team_sports_admin_tasks_url

    assert_redirected_to sports_draws_admin_tasks_path
    assert_match /already finalised/, flash[:notice]
  end

  test "should finalise individual sports" do
    post finalise_individual_sports_admin_tasks_url

    assert_redirected_to sports_draws_admin_tasks_path
    assert_match /individual grades is under way/, flash[:notice]

    @setting.reload
    assert_equal true, @setting.indiv_draws_complete
  end

  test "should not finalise individual sports when already done" do
    @setting.indiv_draws_complete = true
    @setting.save

    post finalise_individual_sports_admin_tasks_url

    assert_redirected_to sports_draws_admin_tasks_path
    assert_match /already finalised/, flash[:notice]
  end
end
