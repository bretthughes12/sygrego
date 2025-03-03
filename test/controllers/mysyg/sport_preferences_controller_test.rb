require "test_helper"

class Mysyg::SportPreferencesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :participant)
    @mysyg_setting = FactoryBot.create(:mysyg_setting)
    @group = @mysyg_setting.group
    FactoryBot.create(:event_detail, group: @group)
    @participant = FactoryBot.create(:participant, group: @group)
    @user.groups << @group
    @user.participants << @participant
    @grade1 = FactoryBot.create(:grade)
    @grade2 = FactoryBot.create(:grade)

    sign_in @user
  end

  test "should get index" do
    get mysyg_sport_preferences_url(group: @group.mysyg_setting.mysyg_name)

    assert_response :success
  end

  test "should update multiple sport preferences" do
    pref1 = FactoryBot.create(:sport_preference, participant: @participant, grade: @grade1)
    pref2 = FactoryBot.create(:sport_preference, participant: @participant, grade: @grade2)

    patch update_multiple_mysyg_sport_preferences_url(
      group: @group.mysyg_setting.mysyg_name,
      sport_preferences: {
        pref1.id => {preference: 3},
        pref2.id => {preference: 7}
      }
    )

    assert_redirected_to mysyg_sports_prefs_url(group: @group.mysyg_setting.mysyg_name)
    assert_match /updated/, flash[:notice]

    pref1.reload
    assert_equal 3, pref1.preference
    pref2.reload
    assert_equal 7, pref2.preference
  end
end
