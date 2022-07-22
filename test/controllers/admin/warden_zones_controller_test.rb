require "test_helper"

class Admin::WardenZonesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @warden_zone = FactoryBot.create(:warden_zone)

    sign_in @user
  end

  test "should get index" do
    get admin_warden_zones_url

    assert_response :success
  end

  test "should show warden_zone" do
    get admin_warden_zone_url(@warden_zone)

    assert_response :success
  end

  test "should not show non existent warden_zone" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_warden_zone_url(12345678)
    }
  end

  test "should get new" do
    get new_admin_warden_zone_url

    assert_response :success
  end

  test "should create warden_zone" do
    assert_difference('WardenZone.count') do
      post admin_warden_zones_path, params: { warden_zone: FactoryBot.attributes_for(:warden_zone) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create warden_zone with errors" do
    assert_no_difference('WardenZone.count') do
      post admin_warden_zones_path, params: { 
                                warden_zone: FactoryBot.attributes_for(:warden_zone,
                                  zone: "X" ) }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_warden_zone_url(@warden_zone)

    assert_response :success
  end

  test "should update warden_zone" do
    patch admin_warden_zone_url(@warden_zone), params: { warden_zone: { zone: 42 } }

    assert_redirected_to admin_warden_zones_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @warden_zone.reload

    assert_equal 42, @warden_zone.zone
  end

  test "should not update warden_zone with errors" do
    patch admin_warden_zone_url(@warden_zone), params: { warden_zone: { zone: "X" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @warden_zone.reload

    assert_not_equal "X", @warden_zone.zone
  end

  test "should destroy warden_zone" do
    assert_difference("WardenZone.count", -1) do
      delete admin_warden_zone_url(@warden_zone)
    end

    assert_redirected_to admin_warden_zones_path
  end

  test "should not destroy non existent warden_zone" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete admin_warden_zone_url(12345678)
    }
  end
end
