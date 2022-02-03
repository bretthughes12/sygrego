require "test_helper"
require 'pp'

class ChartsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    
    sign_in @user
  end

  test "should prepare admin groups chart" do
    FactoryBot.create(:group, new_group: true)

    get admin_groups_charts_url

    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 4, json.length
    assert_equal "New groups", json[0][0]
    assert_equal 1, json[0][1]
  end

  test "should prepare admin participants chart" do
    FactoryBot.create(:participant, spectator: false)

    get admin_participants_charts_url

    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 3, json.length
    assert_equal "Playing sport", json[1][0]
    assert_equal 1, json[1][1]
  end

  test "should prepare gc participants chart" do
    group = FactoryBot.create(:group)
    FactoryBot.create(:participant, group: group, spectator: false)
    gc = FactoryBot.create(:user, :gc)
    group.users << gc
    
    sign_out @user
    sign_in gc

    get gc_participants_charts_url

    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 3, json.length
    assert_equal "Playing sport", json[1][0]
    assert_equal 1, json[1][1]
  end

  test "should prepare evening saturday preferences chart" do
    group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: group, service_pref_sat: "7:00pm")

    get evening_saturday_preferences_charts_url

    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 3, json.length
    assert_equal "Early session", json[0][0]
    assert_equal 1, json[0][1]
  end

  test "should prepare evening sunday preferences chart" do
    group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: group, service_pref_sun: "No preference")

    get evening_sunday_preferences_charts_url

    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 3, json.length
    assert_equal "No preference", json[2][0]
    assert_equal 1, json[2][1]
  end
end
