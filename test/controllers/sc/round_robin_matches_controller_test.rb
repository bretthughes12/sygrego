require "test_helper"

class Sc::RoundRobinMatchesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :sc)
    @section = FactoryBot.create(:section)

    sign_in @user
  end

  test "should get index" do
    get sc_section_round_robin_matches_url(section_id: @section.id)

    assert_response :success
  end
end
