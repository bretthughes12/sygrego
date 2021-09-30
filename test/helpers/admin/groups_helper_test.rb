require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/groups_helper'

class Admin::GroupsHelperTest < ActionView::TestCase
  include Admin::GroupsHelper
  
  def setup
    @user = FactoryBot.create(:user)
    @setting = FactoryBot.create(:setting)
    @group = FactoryBot.create(:group)
  end
  
  test "should display warning about changing short_name" do
    assert_match /Warning: changing this field/, group_short_name_hint(@group)
  end
end  
