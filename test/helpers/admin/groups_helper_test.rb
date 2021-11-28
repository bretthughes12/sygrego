require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/groups_helper'

class Admin::GroupsHelperTest < ActionView::TestCase
  include Admin::GroupsHelper
  
  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @setting = FactoryBot.create(:setting)
    @group = FactoryBot.create(:group)
  end
  
  test "should display warning about changing short_name" do
    assert_match /Warning: changing this field/, group_short_name_hint(@group)
  end
  
  test "group display classes" do
    event_detail = FactoryBot.create(:event_detail, group: @group)
    @group.coming = event_detail.onsite = true
    assert_equal "table-primary", group_display_class(@group)

    @group.event_detail.onsite = false
    assert_equal "table-warning", group_display_class(@group)

    @group.coming = false
    assert_equal "table-dark", group_display_class(@group)
  end
  
  test "group mysyg settings display classes" do
    mysyg_setting = FactoryBot.create(:mysyg_setting, mysyg_enabled: true, mysyg_open: true)
    assert_equal "table-primary", mysyg_settings_display_class(mysyg_setting)

    mysyg_setting.mysyg_open = false
    assert_equal "table-warning", mysyg_settings_display_class(mysyg_setting)

    mysyg_setting.mysyg_enabled = false
    assert_equal "table-dark", mysyg_settings_display_class(mysyg_setting)
  end
  
  test "group rego checklist display classes" do
    rego_checklist = FactoryBot.create(:rego_checklist, registered: true)
    assert_equal "table-primary", rego_display_class(rego_checklist)

    rego_checklist.registered = false
    assert_equal "table-dark", rego_display_class(rego_checklist)
  end
end  
