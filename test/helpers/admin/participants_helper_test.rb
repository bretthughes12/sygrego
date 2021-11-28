require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/participants_helper'

class Admin::ParticipantsHelperTest < ActionView::TestCase
  include Admin::ParticipantsHelper
  
  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @setting = FactoryBot.create(:setting)
    @participant = FactoryBot.create(:participant)
  end
  
  test "participant display classes" do
    @participant.coming = @participant.spectator = true
    assert_equal "table-warning", participant_display_class(@participant)

    @participant.spectator = false
    assert_equal "table-primary", participant_display_class(@participant)

    @participant.coming = false
    assert_equal "table-dark", participant_display_class(@participant)
  end
end