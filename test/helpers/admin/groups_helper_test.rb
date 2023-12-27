require File.dirname(__FILE__) + '/../../test_helper'

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
    assert_equal "table-secondary", group_display_class(@group)

    @group.status = 'Stale'
    assert_equal "table-dark", group_display_class(@group)
  end
  
  test "group submission display classes" do
    assert_equal "table-primary", group_submission_class(@group)

    @group.status = "Submitted"
    assert_equal "table-warning", group_submission_class(@group)
  end
  
  test "group mysyg settings display classes" do
    mysyg_setting = FactoryBot.create(:mysyg_setting, mysyg_enabled: true, mysyg_open: true)
    assert_equal "table-primary", mysyg_settings_display_class(mysyg_setting)

    mysyg_setting.mysyg_open = false
    assert_equal "table-warning", mysyg_settings_display_class(mysyg_setting)

    mysyg_setting.mysyg_enabled = false
    assert_equal "table-dark", mysyg_settings_display_class(mysyg_setting)
  end
  
  test "sport oversubscribed class" do
    session1 = FactoryBot.create(:session)
    session2 = FactoryBot.create(:session)
    section = FactoryBot.create(:section, session: session1)
    entry = FactoryBot.create(:sport_entry, section: section, group: @group)

    assert_equal 'table-danger', sport_oversubscribed_class(@group, session1.id)
    assert_equal 'table-primary', sport_oversubscribed_class(@group, session2.id)
  end
  
  test "group rego checklist display classes" do
    rego_checklist = FactoryBot.create(:rego_checklist, registered: true)
    assert_equal "table-primary", rego_display_class(rego_checklist)

    rego_checklist.registered = false
    assert_equal "table-dark", rego_display_class(rego_checklist)
  end
end  
