require "test_helper"

class Gc::InfoControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    FactoryBot.create(:group)
    
    sign_in @user
  end

  test "should get home page" do
    get home_gc_info_url

    assert_response :success
  end
end
