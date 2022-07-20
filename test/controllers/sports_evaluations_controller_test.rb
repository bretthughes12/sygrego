require "test_helper"

class SportsEvaluationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
  end

  test "should get new" do
    get new_sports_evaluation_url

    assert_response :success
  end

  test "should create sports evaluation" do
    assert_difference('SportsEvaluation.count') do
      post sports_evaluations_path, params: { sports_evaluation: FactoryBot.attributes_for(:sports_evaluation) }
    end

    assert_response :redirect
    assert_match /Thanks for your evaluation/, flash[:notice]
  end
end
