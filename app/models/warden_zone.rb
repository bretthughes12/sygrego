# == Schema Information
#
# Table name: warden_zones
#
#  id          :integer          not null, primary key
#  zone        :integer
#  warden_info :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class WardenZone < ApplicationRecord
    has_many  :groups

    validates :zone, 
        presence: true,
        numericality: { only_integer: true }
  
    def name
      'Zone ' + zone.to_s
    end
end
