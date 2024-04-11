require "test_helper"

class Gc::SportPreferencesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :gc)
    @church_rep = FactoryBot.create(:user, :church_rep)
    @group = FactoryBot.create(:group)
    FactoryBot.create(:mysyg_setting, group: @group)
    FactoryBot.create(:event_detail, group: @group)
    @user.groups << @group
    @church_rep.groups << @group
    @participant = FactoryBot.create(:participant, 
      group: @group)
    @grade = FactoryBot.create(:grade)
    @sport_preference = FactoryBot.create(:sport_preference, participant: @participant, grade: @grade)
    
    sign_in @user
  end

  test "should list sport preferences" do
    get gc_sport_preferences_path

    assert_response :success
  end

  test "should list sport preferences for a church rep" do
    sign_out @user
    sign_in @church_rep

    get gc_sport_preferences_path

    assert_response :success
  end

  test "should list sport preferences with entered option" do
    get gc_sport_preferences_path(entered: 'on')

    assert_response :success
  end

  test "should list sport preferences with in sport option" do
    get gc_sport_preferences_path(in_sport: 'on')

    assert_response :success
  end

  test "should list sport preferences with no option" do
    get gc_sport_preferences_path(commit: 'Filter')

    assert_response :success
  end

  test "should list sport preferences with session-stored options" do
    get gc_sport_preferences_path(in_sport: 'on')
    get gc_sport_preferences_path

    assert_response :success
  end

  test "should download sport preferences" do
    get gc_sport_preferences_path(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should create sport entry from preference" do
    assert_difference('SportEntry.count') do
      post create_sport_entry_gc_sport_preference_path(@sport_preference)
    end

    assert_redirected_to gc_sport_preferences_path
    assert_match /entry created/, flash[:notice]
  end

  test "should create sport entry from preference for a church rep" do
    sign_out @user
    sign_in @church_rep

    assert_difference('SportEntry.count') do
      post create_sport_entry_gc_sport_preference_path(@sport_preference)
    end

    assert_redirected_to gc_sport_preferences_path
    assert_match /entry created/, flash[:notice]
  end

  test "should not create invalid sport entry from preference" do
    SportEntry.any_instance.stubs(:save).returns(false)

    assert_no_difference('SportEntry.count') do
      post create_sport_entry_gc_sport_preference_path(@sport_preference)
    end

    assert_redirected_to gc_sport_preferences_path
    assert_match /There was a problem/, flash[:notice]
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
