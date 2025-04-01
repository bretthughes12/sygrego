# == Schema Information
#
# Table name: payments
#
#  id           :bigint           not null, primary key
#  amount       :decimal(8, 2)    default(0.0), not null
#  name         :string(50)
#  paid         :boolean          default(FALSE)
#  paid_at      :datetime
#  payment_type :string(20)       not null
#  reconciled   :boolean          default(FALSE)
#  reference    :string(50)
#  updated_by   :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  group_id     :bigint           not null
#
# Indexes
#
#  index_payments_on_group_id  (group_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#
require "test_helper"

class PaymentTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def setup
    @user = FactoryBot.create(:user, :admin)
    @setting = FactoryBot.create(:setting)
    @payment = FactoryBot.create(:payment)
  end

  test "should display date paid" do
    assert_equal '', @payment.date_paid

    now = Time.now
    @payment.paid_at = now
    assert_equal now.in_time_zone.strftime('%d/%m/%Y'), @payment.date_paid
  end
end
