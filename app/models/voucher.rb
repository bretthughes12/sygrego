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
class Voucher < ApplicationRecord
  belongs_to :group, optional: true
  has_many :participants

  require 'pp'

  TYPES = %w[
    Set
    Multiply
    Divide
    Add
    Subtract
  ].freeze

  RESTRICTIONS = %w[
    Helpers
  ].freeze

  validates :name,
    presence: true,
    uniqueness: true,
    length: { maximum: 20 }
  validates :limit,                 
    numericality: { only_integer: true }
  validates :restricted_to,
    length: { maximum: 20 },
    inclusion: { in: RESTRICTIONS },
    allow_blank: true
  validates :adjustment,                 
    presence: true,
    numericality: true,
    inclusion: { in: 0..999.99 }
  validates :voucher_type,
    presence: true,
    length: { maximum: 15 },
    inclusion: { in: TYPES }
  
  before_save :uppercase_name!
  before_validation :check_for_divide_by_zero

  def valid_for?(participant)
    return false if participant.nil?
    unless limit.nil?
      return false if participants.count >= limit
    end
    unless group.nil?
      return false if group != participant.group
    end
    unless expiry.nil?
      return false if Date.today.in_time_zone > expiry
    end
    unless restricted_to.nil?
      return false if restricted_to == "Helpers" && !participant.helper
    end
    return true
  end

  def apply(fee)
    case voucher_type
    when 'Multiply'
      fee * adjustment
    when 'Divide'
      fee / adjustment
    when 'Add'
      fee + adjustment
    when 'Subtract'
      fee - adjustment
    when 'Set'
      adjustment
    else
      fee
    end
  end

  def effect
    case
    when voucher_type == "Multiply" && adjustment == 0
      'Free'
    when voucher_type == "Multiply" && adjustment < 1
      "#{((1 - adjustment) * 100).to_i}% off"
    when voucher_type == "Multiply"
      "Multiply by #{adjustment}"
    when voucher_type == "Set" && adjustment == 0
      'Free'
    when voucher_type == "Set"
      "$#{adjustment}"
    when voucher_type == "Subtract"
      "$#{adjustment} off"
    when voucher_type == "Divide"
      "Divide by #{adjustment}"
    when voucher_type == "Add"
      "Add $#{adjustment}"
    end
  end

  private

  def check_for_divide_by_zero
    errors.add(:voucher_type, 'Divide by zero is not allowed') if voucher_type == "Divide" && adjustment == 0.0
  end

  def uppercase_name!
    name.upcase!
  end
end
