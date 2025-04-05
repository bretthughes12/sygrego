require File.dirname(__FILE__) + '/../../test_helper'

class Admin::PaymentsHelperTest < ActionView::TestCase
  include Admin::PaymentsHelper
  
  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @setting = FactoryBot.create(:setting)
    @payment = FactoryBot.create(:payment)
  end
  
  test "payment display classes" do
    @payment.reconciled = true
    assert_equal "table-primary", payment_display_class(@payment)

    @payment.reconciled = false
    @payment.paid = true
    assert_equal "table-warning", payment_display_class(@payment)

    @payment.paid = false
    assert_equal "table-dark", payment_display_class(@payment)
  end
end