# == Schema Information
#
# Table name: payments
#
#  id           :bigint           not null, primary key
#  amount       :decimal(8, 2)    default(0.0), not null
#  invoice_type :string(20)       default("Unspecified"), not null
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
FactoryBot.define do
  factory :payment do
    group 
    amount { "100.00" }
    payment_type { "Direct Deposit" }
    invoice_type { "Initial" }
  end
end
