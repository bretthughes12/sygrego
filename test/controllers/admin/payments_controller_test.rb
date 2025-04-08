require "test_helper"

class Admin::PaymentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @payment = FactoryBot.create(:payment)
    
    sign_in @user
  end

  test "should get index" do
    get admin_payments_url

    assert_response :success
  end

  test "should download payment data" do
    get admin_payments_url(format: :xlsx)

    assert_response :success
    assert_match %r{application\/vnd.openxmlformats-officedocument.spreadsheetml.sheet}, @response.content_type
  end

  test "should show payment" do
    get admin_payment_url(@payment)

    assert_response :success
  end

  test "should not show non existent payment" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_payment_url(12345678)
    }
  end

  test "should get new" do
    get new_admin_payment_url

    assert_response :success
  end

  test "should create payment" do
    group = FactoryBot.create(:group)

    assert_difference('Payment.count') do
      post admin_payments_path, params: { payment: FactoryBot.attributes_for(:payment, group_id: group.id) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create payment with errors" do
    assert_no_difference('Payment.count') do
      post admin_payments_path, params: { 
        payment: FactoryBot.attributes_for(:payment,
          amount: "a") }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_payment_url(@payment)

    assert_response :success
  end

  test "should update payment" do
    patch admin_payment_url(@payment), 
      params: { payment: { amount: 150.0 } }

    assert_redirected_to admin_payments_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @payment.reload

    assert_equal 150.0, @payment.amount
  end

  test "should not update payment with errors" do
    patch admin_payment_url(@payment), 
      params: { payment: { amount: "a" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @payment.reload

    assert_not_equal "a", @payment.amount
  end

  test "should reconcile payment" do
    patch reconcile_admin_payment_url(@payment)

    assert_redirected_to admin_payments_path
    assert_match /reconciled/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @payment.reload

    assert @payment.reconciled
  end

  test "should destroy payment" do
    assert_difference("Payment.count", -1) do
      delete admin_payment_url(@payment)
    end

    assert_redirected_to admin_payments_path
  end

  test "should not destroy non existent payment" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete admin_payment_url(12345678)
    }
  end
end
