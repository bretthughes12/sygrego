require "test_helper"

class Admin::SportsEvaluationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @sports_evaluation = FactoryBot.create(:sports_evaluation)

    sign_in @user
  end

  test "should get index" do
    get admin_sports_evaluations_url

    assert_response :success
  end

  test "should download sports_evaluation data as csv" do
    get admin_sports_evaluations_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should download sports_evaluation data as pdf" do
    get admin_sports_evaluations_url(format: :pdf)

    assert_response :success
    assert_match %r{application\/pdf}, @response.content_type
  end

  test "should show sports_evaluation" do
    get admin_sports_evaluation_url(@sports_evaluation)

    assert_response :success
  end

  test "should not show non existent sports_evaluation" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_sports_evaluation_url(12345678)
    }
  end

  test "should get new" do
    get new_admin_sports_evaluation_url

    assert_response :success
  end

  test "should create sports_evaluation" do
    assert_difference('SportsEvaluation.count') do
      post admin_sports_evaluations_path, params: { sports_evaluation: FactoryBot.attributes_for(:sports_evaluation) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create sports_evaluation with errors" do
    assert_no_difference('SportsEvaluation.count') do
      post admin_sports_evaluations_path, params: { 
                                sports_evaluation: FactoryBot.attributes_for(:sports_evaluation,
                                  section: "this code is too long.............................." ) }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_sports_evaluation_url(@sports_evaluation)

    assert_response :success
  end

  test "should update sports_evaluation" do
    patch admin_sports_evaluation_url(@sports_evaluation), params: { sports_evaluation: { sport: "Fishing" } }

    assert_redirected_to admin_sports_evaluations_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @sports_evaluation.reload

    assert_equal "Fishing", @sports_evaluation.sport
  end

  test "should not update sports_evaluation with errors" do
    patch admin_sports_evaluation_url(@sports_evaluation), params: { sports_evaluation: { section: "this code is too long.............................." } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @sports_evaluation.reload

    assert_not_equal "this code is too long..............................", @sports_evaluation.section
  end

  test "should destroy sports_evaluation" do
    assert_difference("SportsEvaluation.count", -1) do
      delete admin_sports_evaluation_url(@sports_evaluation)
    end

    assert_redirected_to admin_sports_evaluations_path
  end

  test "should not destroy non existent sports_evaluation" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete admin_sports_evaluation_url(12345678)
    }
  end
end
