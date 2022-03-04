# == Schema Information
#
# Table name: vouchers
#
#  id           :bigint           not null, primary key
#  adjustment   :decimal(8, )     default(0), not null
#  expiry       :datetime
#  limit        :integer          default(1)
#  name         :string(20)       not null
#  voucher_type :string(15)       default("Multiply"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  group_id     :bigint
#
# Indexes
#
#  index_vouchers_on_group_id  (group_id)
#
require "test_helper"

class VoucherTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def setup
      FactoryBot.create(:role, name: 'admin')
      @user = FactoryBot.create(:user)
      @voucher = FactoryBot.create(:voucher, limit: 1)
  end

  test "should allow defaut voucher for a participant" do
    participant = FactoryBot.create(:participant)

    assert_equal true, @voucher.valid_for?(participant)
  end

  test "should allow voucher for a participant in same group" do
    participant = FactoryBot.create(:participant)
    voucher = FactoryBot.create(:voucher, group: participant.group)

    assert_equal true, voucher.valid_for?(participant)
  end

  test "should not allow voucher for a participant in wrong group" do
    participant = FactoryBot.create(:participant)
    group = FactoryBot.create(:group)
    voucher = FactoryBot.create(:voucher, group: group)

    assert_equal false, voucher.valid_for?(participant)
  end

  test "should not allow voucher for a participant when vouchers are used up" do
    FactoryBot.create(:participant, voucher: @voucher)
    participant = FactoryBot.create(:participant)

    assert_equal false, @voucher.valid_for?(participant)
  end

  test "should allow unexpired voucher for a participant" do
    participant = FactoryBot.create(:participant)
    voucher = FactoryBot.create(:voucher, expiry: Date.today)

    assert_equal true, voucher.valid_for?(participant)
  end

  test "should not allow expired voucher for a participant" do
    participant = FactoryBot.create(:participant)
    voucher = FactoryBot.create(:voucher, expiry: 1.day.ago)

    assert_equal false, voucher.valid_for?(participant)
  end
end
