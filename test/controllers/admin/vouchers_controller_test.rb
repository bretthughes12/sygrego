require "test_helper"

class Admin::VouchersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @voucher = FactoryBot.create(:voucher)
    
    sign_in @user
  end

  test "should get index" do
    get admin_vouchers_url

    assert_response :success
  end

  test "should download voucher data" do
    get admin_vouchers_url(format: :xlsx)

    assert_response :success
    assert_match %r{application\/vnd.openxmlformats-officedocument.spreadsheetml.sheet}, @response.content_type
  end

  test "should show voucher" do
    get admin_voucher_url(@voucher)

    assert_response :success
  end

  test "should not show non existent voucher" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_voucher_url(12345678)
    }
  end

  test "should get new" do
    get new_admin_voucher_url

    assert_response :success
  end

  test "should create voucher" do
    assert_difference('Voucher.count') do
      post admin_vouchers_path, params: { voucher: FactoryBot.attributes_for(:voucher) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create voucher with errors" do
    assert_no_difference('Voucher.count') do
      post admin_vouchers_path, params: { 
        voucher: FactoryBot.attributes_for(:voucher,
          limit: "a") }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_voucher_url(@voucher)

    assert_response :success
  end

  test "should update voucher" do
    patch admin_voucher_url(@voucher), 
      params: { voucher: { name: "Elvis" } }

    assert_redirected_to admin_vouchers_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @voucher.reload

    assert_equal "ELVIS", @voucher.name
  end

  test "should not update voucher with errors" do
    patch admin_voucher_url(@voucher), 
      params: { voucher: { limit: "a" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @voucher.reload

    assert_not_equal "a", @voucher.limit
  end

  test "should destroy voucher" do
    assert_difference("Voucher.count", -1) do
      delete admin_voucher_url(@voucher)
    end

    assert_redirected_to admin_vouchers_path
  end

  test "should not destroy non existent voucher" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete admin_voucher_url(12345678)
    }
  end
end
