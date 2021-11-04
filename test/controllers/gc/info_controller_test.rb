require "test_helper"

class Gc::InfoControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :gc)
    @group = FactoryBot.create(:group)
    @user.groups << @group

    sign_in @user
  end

  test "should get home page" do
    get home_gc_info_url

    assert_response :success
  end
end
