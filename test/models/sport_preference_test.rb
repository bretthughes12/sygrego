# == Schema Information
#
# Table name: sport_preferences
#
#  id             :bigint           not null, primary key
#  level          :string(100)
#  preference     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  participant_id :bigint           not null
#  sport_id       :bigint
#
# Indexes
#
#  index_sport_preferences_on_participant_id  (participant_id)
#  index_sport_preferences_on_sport_id        (sport_id)
#
# Foreign Keys
#
#  fk_rails_...  (participant_id => participants.id)
#  fk_rails_...  (sport_id => sports.id)
#

require "test_helper"

class SportPreferenceTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def setup
    FactoryBot.create(:setting)
    FactoryBot.create(:user, :admin)
    @group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: @group)
    FactoryBot.create(:mysyg_setting, group: @group)
    @participant = FactoryBot.create(:participant, group: @group)
    @sport1 = FactoryBot.create(:sport, name: "First")
    @sport2 = FactoryBot.create(:sport, name: "Second")
    @sport_preference1 = FactoryBot.create(:sport_preference, 
      participant: @participant, 
      sport: @sport1)
    @sport_preference2 = FactoryBot.create(:sport_preference, 
      participant: @participant, 
      sport: @sport2)
  end

  test "should order by grade name" do
    assert_equal -1, @sport_preference1 <=> @sport_preference2
  end

  test "should locate preferences for a participant" do
    prefs = SportPreference.locate_for_participant(@participant)

    assert_equal 2, prefs.size
    assert_equal @sport_preference1, prefs.first
    assert_equal @sport_preference2, prefs.last
  end

  test "should prepare preferences for a participant" do
    FactoryBot.create(:grade, sport: @sport1)
    FactoryBot.create(:grade, sport: @sport2)
    participant = FactoryBot.create(:participant, group: @group)
    prefs = []

    assert_difference('SportPreference.count', 2) do
      prefs = SportPreference.prepare_for_participant(participant)
    end

    assert_equal 2, prefs.size
    assert_equal "First", prefs.first.sport.name
    assert_equal "Second", prefs.last.sport.name
  end

  test "should not prepare preferences for a nil participant" do
    prefs = []

    assert_no_difference('SportPreference.count') do
      prefs = SportPreference.prepare_for_participant(nil)
    end

    assert_equal 0, prefs.size
  end

  test "should update a preference for a participant" do
    SportPreference.store(@participant.id, @sport1.id, 3)

    @sport_preference1.reload
    assert_equal 3, @sport_preference1.preference
  end

  test "should locate preferences for a group" do
    prefs = SportPreference.locate_for_group(@group)

    assert_equal 2, prefs.size
    assert_equal @sport_preference1, prefs.first
    assert_equal @sport_preference2, prefs.last
  end

  test "should locate preferences for a group excluding already entered" do
    grade = FactoryBot.create(:grade, sport: @sport1)
    entry = FactoryBot.create(:sport_entry, group: @group, grade: grade)
    entry.participants << @participant

    prefs = SportPreference.locate_for_group(@group, {entered: false})

    assert_equal 1, prefs.size
    assert_equal @sport_preference2, prefs.last
  end

  # test "should locate preferences for a group excluding already in sport" do
  #   grade = FactoryBot.create(:grade, sport: @grade2.sport)
  #   entry = FactoryBot.create(:sport_entry, group: @group, grade: grade)
  #   entry.participants << @participant

  #   prefs = SportPreference.locate_for_group(@group, {in_sport: false})

  #   assert_equal 1, prefs.size
  #   assert_equal @sport_preference1, prefs.first
  # end

  test "should show comment for entry when not entered" do
    grade = FactoryBot.create(:grade, sport: @sport1)
    entry = FactoryBot.create(:sport_entry, group: @group, grade: grade)

    assert_equal '', @sport_preference1.entry_comment(entry)
  end

  test "should show comment for entry when entered in sport" do
    grade = FactoryBot.create(:grade, sport: @sport1)
    entry = FactoryBot.create(:sport_entry, group: @group, grade: grade)
    entry.participants << @participant

    assert_equal 'Sport clash (not allowed)', @sport_preference1.entry_comment(entry)
  end

  # test "should show comment for entry in a different grade of same sport" do
  #   grade = FactoryBot.create(:grade, sport: @grade2.sport)
  #   entry = FactoryBot.create(:sport_entry, group: @group, grade: grade)

  #   assert_equal 'Different grade', @sport_preference2.entry_comment(entry)
  # end
end
