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
class Voucher < ApplicationRecord
  belongs_to :group, optional: true
  has_many :participants

  TYPES = %w[
    Set
    Multiply
    Divide
    Add
    Subtract
  ].freeze

  validates :limit,                 
    numericality: { only_integer: true }
  validates :adjustment,                 
    presence: true,
    numericality: true,
    inclusion: { in: 0..999.99 }
  validates :type,
    presence: true,
    length: { maximum: 15 },
    inclusion: TYPES
  
end
