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
class Payment < ApplicationRecord
  belongs_to :group

  scope :reconciled, -> { where(reconciled: true) }
  scope :unreconciled, -> { where(reconciled: false) }

  PAYMENT_TYPES = ['Bank Cheque',
    'Cheque',
    'Direct Deposit'].freeze

  validates :amount,                 
    presence: true,
    numericality: true,
    inclusion: { in: 0..999_999.99 }
  validates :payment_type,
    presence: true,
    length: { maximum: 20 }
  validates :name, 
    length: { maximum: 50 }
  validates :reference, 
    length: { maximum: 50 }

  before_validation :check_for_valid_amount

  def date_paid
    paid_at.nil? ? '' : paid_at.in_time_zone.strftime('%d/%m/%Y')
  end

  def invoice_number
    return 'INV' + id.to_s.rjust(6, '0') if id
  end

private

  def check_for_valid_amount
    errors.add(:amount, 'should be at least 0.01') if amount.nil? || amount < 0.01
  end
end
