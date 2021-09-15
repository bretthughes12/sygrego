# == Schema Information
#
# Table name: venues
#
#  id            :bigint           not null, primary key
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

    validates :name,                    presence: true,
                                        uniqueness: true,
                                        length: { maximum: 50 }
    validates :database_code,           uniqueness: true,
                                        length: { maximum: 4 }
    validates :address,                 length: { maximum: 255 }
  
#    acts_as_gmappable lat: 'lat',
#                      lng: 'lng',
#                      check_process: false,
#                      validation: false,
#                      address: 'address'
end
