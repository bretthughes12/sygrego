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
FactoryBot.define do
  factory :voucher do
    sequence(:name) { |n| "Voucher#{n}"}
    limit { 1 }
    restricted_to { nil }
    voucher_type { "Multiply" }
    adjustment { "1.0" }
  end
end
