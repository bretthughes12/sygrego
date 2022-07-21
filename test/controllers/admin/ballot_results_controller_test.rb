require "test_helper"

class Admin::BallotResultsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @ballot_result = FactoryBot.create(:ballot_result)
    
    sign_in @user
  end

  test "should download ballot data" do
    get admin_ballot_results_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should get summary" do
    get summary_admin_ballot_results_url

    assert_response :success
  end
end 
