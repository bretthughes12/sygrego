require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/roles_helper'

class Admin::RolesHelperTest < ActionView::TestCase
  include Admin::RolesHelper
  
  def setup
    @admin = FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @setting = FactoryBot.create(:setting)
    @role = FactoryBot.create(:role)
  end
  
  test "should use primary class for admin role" do
    assert_match /primary/, role_badge_class(@admin)
  end
  
  test "should use success class for gc role" do
    role = FactoryBot.create(:role, name: 'gc')
    assert_match /success/, role_badge_class(role)
  end
  
  test "should use info class for church_rep role" do
    role = FactoryBot.create(:role, name: 'church_rep')
    assert_match /info/, role_badge_class(role)
  end
  
  test "should use secondary class for participant role" do
    role = FactoryBot.create(:role, name: 'participant')
    assert_match /secondary/, role_badge_class(role)
  end
end  
