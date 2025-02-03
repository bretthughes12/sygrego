require "test_helper"

class Admin::OrientationDetailsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @orientation_detail = FactoryBot.create(:orientation_detail)
    
    sign_in @user
  end

  test "should get index" do
    get admin_orientation_details_url

    assert_response :success
  end

  test "should show orientation_detail" do
    get admin_orientation_detail_url(@orientation_detail)

    assert_response :success
  end

  test "should get new" do
    get new_admin_orientation_detail_url

    assert_response :success
  end

  test "should create orientation_detail" do
    assert_difference('OrientationDetail.count') do
      post admin_orientation_details_url, params: { orientation_detail: { name: 'New Orientation' } }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_orientation_detail_url(@orientation_detail)

    assert_response :success
  end

  test "should update orientation_detail" do
    patch admin_orientation_detail_url(@orientation_detail), params: { orientation_detail: { name: 'Updated Orientation' } }

    assert_redirected_to admin_orientation_details_path
    @orientation_detail.reload
    assert_equal 'Updated Orientation', @orientation_detail.name
  end

  test "should destroy orientation_detail" do
    assert_difference('OrientationDetail.count', -1) do
      delete admin_orientation_detail_url(@orientation_detail)
    end

    assert_redirected_to admin_orientation_details_path
  end
end