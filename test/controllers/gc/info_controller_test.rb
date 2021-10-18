require "test_helper"

class Gc::InfoControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    admin_role = FactoryBot.create(:role, name: 'admin')
    gc_role = FactoryBot.create(:role, name: 'gc')
    @user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: @group)
    
    @user.roles.delete(admin_role)
    @user.roles << gc_role

    sign_in @user
  end

  test "should get home page" do
    get home_gc_info_url

    assert_response :success
  end
end
