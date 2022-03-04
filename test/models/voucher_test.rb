# == Schema Information
#
# Table name: vouchers
#
#  id         :bigint           not null, primary key
#  adjustment :decimal(8, )     default(0), not null
#  expiry     :datetime
#  limit      :integer          default(1)
#  name       :string(20)       not null
#  type       :string(15)       default("Multiply"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :bigint
#
# Indexes
#
#  index_vouchers_on_group_id  (group_id)
#
require "test_helper"

class VoucherTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
