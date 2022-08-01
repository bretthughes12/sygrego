require "test_helper"

class Gc::SportPreferencesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :gc)
    @church_rep = FactoryBot.create(:user, :church_rep)
    @group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: @group)
    @user.groups << @group
    @church_rep.groups << @group
    @participant = FactoryBot.create(:participant, group: @group)
    @grade = FactoryBot.create(:grade)
    @sport_preference = FactoryBot.create(:sport_preference, participant: @participant, grade: @grade)
    
    sign_in @user
  end

  test "should list sport preferences" do
    get gc_sport_preferences_path

    assert_response :success
  end

  test "should create sport entry from preference" do
    assert_difference('SportEntry.count') do
      post create_sport_entry_gc_sport_preference_path(@sport_preference)
    end

    assert_redirected_to gc_sport_preferences_path
    assert_match /entry created/, flash[:notice]
  end

  test "should add participant with preference to sport entry" do
    entry = FactoryBot.create(:sport_entry, grade: @grade, group: @group)

    post add_to_sport_entry_gc_sport_preference_path(@sport_preference)

    assert_redirected_to gc_sport_preferences_path
    assert_match /Participant added/, flash[:notice]

    entry.reload
    assert entry.participants.include?(@participant)
  end

  test "should remove participant with preference from sport entry" do
    entry = FactoryBot.create(:sport_entry, grade: @grade, group: @group)
    entry.participants << @participant

    delete remove_from_sport_entry_gc_sport_preference_path(@sport_preference)

    assert_redirected_to gc_sport_preferences_path
    assert_match /Participant removed/, flash[:notice]

    entry.reload
    assert !entry.participants.include?(@participant)
  end
end
