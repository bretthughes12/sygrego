# == Schema Information
#
# Table name: group_fee_categories
#
#  id              :bigint           not null, primary key
#  adjustment_type :string(15)       default("Add")
#  amount          :decimal(8, 2)    default(1.0)
#  description     :string(40)
#  expiry_date     :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  group_id        :bigint           not null
#
# Indexes
#
#  index_group_fee_categories_on_group_id  (group_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#
FactoryBot.define do
  factory :group_fee_category do
    group { nil }
    description { "MyString" }
    adjustment_type { "MyString" }
    amount { "9.99" }
  end
end
