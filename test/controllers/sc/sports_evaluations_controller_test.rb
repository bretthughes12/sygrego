require "test_helper"

class Sc::SportsEvaluationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :sc)
    @sports_evaluation = FactoryBot.create(:sports_evaluation)

    sign_in @user
  end

  test "should get new" do
    get new_sc_sports_evaluation_url

    assert_response :success
  end

  test "should create sports_evaluation" do
    assert_difference('SportsEvaluation.count') do
      post sc_sports_evaluations_path, params: { sports_evaluation: FactoryBot.attributes_for(:sports_evaluation) }
    end

    assert_redirected_to new_sc_sports_evaluation_url
    assert_match /Thanks for your evaluation/, flash[:notice]
  end

  test "should not create sports_evaluation with errors" do
    assert_no_difference('SportsEvaluation.count') do
      post sc_sports_evaluations_path, params: { 
                                sports_evaluation: FactoryBot.attributes_for(:sports_evaluation,
                                  section: "this code is too long.............................." ) }
    end

    assert_response :success
  end
end
