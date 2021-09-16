# == Schema Information
#
# Table name: venues
#
#  id            :bigint           not null, primary key
#  active        :boolean
#  address       :string
#  database_code :string(4)
#  name          :string(50)       default(""), not null
#  updated_by    :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Venue < ApplicationRecord
    include Auditable
 
#    has_many :sport_sections

    scope :active, -> { where(active: true) }

    validates :name,                    presence: true,
                                        uniqueness: true,
                                        length: { maximum: 50 }
    validates :database_code,           uniqueness: true,
                                        length: { maximum: 4 }
    validates :address,                 length: { maximum: 255 }
  

    private

    def self.sync_fields
        ['name',
         'address']
    end
end
