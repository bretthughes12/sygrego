require File.dirname(__FILE__) + '/../../test_helper'

class Admin::SportPreferencesHelperTest < ActionView::TestCase
  include Admin::SportPreferencesHelper
  
  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @setting = FactoryBot.create(:setting)
    @group = FactoryBot.create(:group)
    FactoryBot.create(:mysyg_setting, group: @group)
    FactoryBot.create(:event_detail, group: @group)
    @player = FactoryBot.create(:participant, group: @group)
    @pref = FactoryBot.create(:sport_preference, participant: @player)
  end
  
  test "sport preference display classes" do
    sport = FactoryBot.create(:sport)
    grade1 = FactoryBot.create(:grade, sport: sport)
    entry = FactoryBot.create(:sport_entry, group: @group, grade: grade1)
    entry.participants << @player

    assert_equal "table-secondary", sport_pref_class(@pref)

    pref2 = FactoryBot.create(:sport_preference, sport: sport, participant: @player)
    assert_equal "table-primary", sport_pref_class(pref2)
  end
end