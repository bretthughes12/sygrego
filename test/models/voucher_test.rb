# == Schema Information
#
# Table name: vouchers
#
#  id            :bigint           not null, primary key
#  adjustment    :decimal(8, 2)    default(1.0), not null
#  expiry        :datetime
#  limit         :integer          default(1)
#  name          :string(20)       not null
#  restricted_to :string(20)
#  voucher_type  :string(15)       default("Multiply"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  group_id      :bigint
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

  test "should not allow expired voucher for a new participant" do
    participant = FactoryBot.build(:participant)
    voucher = FactoryBot.create(:voucher, expiry: 1.day.ago)

    assert_equal false, voucher.valid_for?(participant)
  end

  test "should not allow expired voucher for an old participant" do
    participant = FactoryBot.create(:participant)
    voucher = FactoryBot.create(:voucher, expiry: 1.day.ago)

    assert_equal false, voucher.valid_for?(participant)
  end

  test "should allow helpers voucher for a helper participant" do
    participant = FactoryBot.build(:participant, spectator: true, helper: true)
    voucher = FactoryBot.create(:voucher, restricted_to: "Helpers")

    assert_equal true, voucher.valid_for?(participant)
  end

  test "should not allow helpers voucher for a normal participant" do
    participant = FactoryBot.create(:participant)
    voucher = FactoryBot.create(:voucher, restricted_to: "Helpers")

    assert_equal false, voucher.valid_for?(participant)
  end

  test "should apply a multiple voucher" do
    voucher = FactoryBot.create(:voucher, voucher_type: "Multiply", adjustment: 0.5)

    assert_equal 10, voucher.apply(20)
  end

  test "should apply a divide voucher" do
    voucher = FactoryBot.create(:voucher, voucher_type: "Divide", adjustment: 3)

    assert_equal 3, voucher.apply(9)
  end

  test "should apply a subtract voucher" do
    voucher = FactoryBot.create(:voucher, voucher_type: "Subtract", adjustment: 5.0)

    assert_equal 15, voucher.apply(20)
  end

  test "should apply a addition voucher" do
    voucher = FactoryBot.create(:voucher, voucher_type: "Add", adjustment: 5)

    assert_equal 25, voucher.apply(20)
  end

  test "should apply a set voucher" do
    voucher = FactoryBot.create(:voucher, voucher_type: "Set", adjustment: 10)

    assert_equal 10, voucher.apply(50)
  end

  test "should not apply an invalid voucher" do
    voucher = FactoryBot.create(:voucher, voucher_type: "Set", adjustment: 10)
    voucher.voucher_type = "Invalid"

    assert_equal 50, voucher.apply(50)
  end
end
