require "test_helper"

class Gc::PaymentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :gc)
    @church_rep = FactoryBot.create(:user, :church_rep)
    @group = FactoryBot.create(:group)
    @user.groups << @group
    @church_rep.groups << @group
    @payment = FactoryBot.create(:payment, group: @group)
    
    sign_in @user
  end

  test "should get index" do
    get gc_payments_url

    assert_response :success
  end

  test "should show payment" do
    get gc_payment_url(@payment)

    assert_response :success
  end

  test "should show payment for church rep user" do
    sign_out @user
    sign_in @church_rep

    get gc_payment_url(@payment)

    assert_response :success
  end

  test "should not show non existent payment" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get gc_payment_url(12345678)
    }
  end

  test "should get new" do
    get new_gc_payment_url

    assert_response :success
  end

  test "should create payment" do
    group = FactoryBot.create(:group)

    assert_difference('Payment.count') do
      post gc_payments_path, params: { payment: FactoryBot.attributes_for(:payment) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create payment with errors" do
    assert_no_difference('Payment.count') do
      post gc_payments_path, params: { 
        payment: FactoryBot.attributes_for(:payment,
          amount: 0) }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_gc_payment_url(@payment)

    assert_response :success
  end

  test "should update payment" do
    patch gc_payment_url(@payment), 
      params: { payment: { name: "Elvis" } }

    assert_redirected_to gc_payments_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @payment.reload

    assert_equal "Elvis", @payment.name
  end

  test "should not update payment with errors" do
    patch gc_payment_url(@payment), 
      params: { payment: { amount: "a" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @payment.reload

    assert_not_equal "a", @payment.amount
  end

  test "should not update reconciled payment" do
    reconciled = FactoryBot.create(:payment, reconciled: true, group: @group)

    patch gc_payment_url(reconciled), 
      params: { payment: { amount: 123.00 } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    reconciled.reload

    assert_not_equal 123.00, reconciled.amount
  end

  test "should destroy payment" do
    assert_difference("Payment.count", -1) do
      delete gc_payment_url(@payment)
    end

    assert_redirected_to gc_payments_path
  end

  test "should not destroy non existent payment" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete gc_payment_url(12345678)
    }
  end

  test "should not destroy reconciled payment" do
    reconciled = FactoryBot.create(:payment, reconciled: true, group: @group)

    assert_no_difference("Payment.count") do
      delete gc_payment_url(reconciled)
    end

    assert_redirected_to gc_payments_path
  end
end
