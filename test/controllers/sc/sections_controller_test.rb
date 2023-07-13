require "test_helper"

class Sc::SectionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :sc)

    sign_in @user
  end

  test "should get index" do
    get sc_sections_url

    assert_response :success
  end
end
