# == Schema Information
#
# Table name: lost_items
#
#  id           :bigint           not null, primary key
#  address      :string(200)
#  category     :string(30)       not null
#  claimed      :boolean          default(FALSE)
#  description  :string(255)      not null
#  email        :string(100)
#  lock_version :integer          default(0)
#  name         :string(40)
#  phone_number :string(30)
#  postcode     :integer
#  suburb       :string(40)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class LostItem < ApplicationRecord
    include Searchable

    scope :claimed, -> { where(claimed: true) }
    scope :unclaimed, -> { where(claimed: false) }
  
    validates :description,            presence: true,
                                       length: { maximum: 255 }
    validates :category,               presence: true,
                                       length: { maximum: 30 }
    validates :email,                  length: { maximum: 100 },
                                       format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
                                                 message: 'invalid format' },
                                       allow_blank: true
    validates :name,                   length: { maximum: 40 }
    validates :address,                length: { maximum: 200 }
    validates :suburb,                 length: { maximum: 40 }
    validates :postcode,               numericality: { only_integer: true },
                                       allow_blank: true
    validates :phone_number,           length: { maximum: 30 }
  
    with_options if: proc { |i| i.claimed } do |claimed_item|
      claimed_item.validates :name,         presence: true
      claimed_item.validates :address,      presence: true
      claimed_item.validates :suburb,       presence: true
      claimed_item.validates :postcode,     presence: true
      claimed_item.validates :phone_number, presence: true
      claimed_item.validates :email,        presence: true
    end
  
    has_one_attached :photo

    searchable_by :category, :description
end
