require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/participants_helper'

class Admin::ParticipantsHelperTest < ActionView::TestCase
  include Admin::ParticipantsHelper
  
  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @setting = FactoryBot.create(:setting)
    @group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: @group)
    @participant = FactoryBot.create(:participant, group: @group)
  end
  
  test "participant display classes" do
    @participant.status = 'Requiring Approval'
    assert_equal "table-secondary", participant_display_class(@participant)

    @participant.status = 'Accepted'
    @participant.coming = @participant.spectator = true
    assert_equal "table-warning", participant_display_class(@participant)

    @participant.spectator = false
    assert_equal "table-primary", participant_display_class(@participant)

    @participant.coming = false
    assert_equal "table-dark", participant_display_class(@participant)
  end

  test "participant acceptance display classes" do
    assert_equal "badge bg-success", participant_status_class(@participant)

    @participant.status = "Requiring Approval"
    assert_equal "badge bg-danger", participant_status_class(@participant)
  end

  test "participant type display classes" do
    assert_equal "badge bg-success", participant_type_class(@participant)

    @participant.coming_friday = false
    @participant.save
    assert_equal "badge bg-primary", participant_type_class(@participant)
  end

  test "should include group name with name" do
    name = @participant.name + ' (' + @participant.group.short_name + ')'
    assert_equal name, name_with_group_name(@participant)

    @participant.group = nil
    assert_equal @participant.name, name_with_group_name(@participant)
  end

  test "should include captain with name" do
    name = @participant.name + ' (c)'
    assert_equal name, name_with_captaincy_suffix(@participant, @participant)

    not_captain = FactoryBot.create(:participant, group: @group)
    assert_equal @participant.name, name_with_captaincy_suffix(@participant, not_captain)
  end
end