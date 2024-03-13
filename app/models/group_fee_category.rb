# == Schema Information
#
# Table name: group_fee_categories
#
#  id              :bigint           not null, primary key
#  adjustment_type :string(15)       default("Add")
#  amount          :decimal(8, 2)    default(1.0)
#  description     :string(40)
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
class GroupFeeCategory < ApplicationRecord
  belongs_to :group

  TYPES = %w[
    Set
    Add
    Subtract
  ].freeze

  validates :description,
    presence: true,
    length: { maximum: 440 }
  validates :amount,                 
    presence: true,
    numericality: true,
    inclusion: { in: 0..999.99 }
  validates :adjustment_type,
    presence: true,
    length: { maximum: 15 },
    inclusion: { in: TYPES }

  def apply(fee)
    case adjustment_type
    when 'Add'
      fee + amount
    when 'Subtract'
      fee - amount
    when 'Set'
      amount
    else
      fee
    end
  end
  
  def effect
    case
    when adjustment_type == "Set" && amount == 0
      'Free'
    when adjustment_type == "Set"
      "$#{amount}"
    when adjustment_type == "Subtract"
      "$#{amount} off"
    when adjustment_type == "Add"
      "Add $#{amount}"
    end
  end
end
