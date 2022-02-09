# == Schema Information
#
# Table name: venues
#
#  id            :integer          not null, primary key
#  name          :string(50)       default(""), not null
#  database_code :string(4)
#  address       :string
#  updated_by    :integer
#  active        :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_venues_on_database_code  (database_code) UNIQUE
#  index_venues_on_name           (name) UNIQUE
#

class Venue < ApplicationRecord
    include Auditable
 
    require 'csv'

    has_many :sections

    scope :active, -> { where(active: true) }

    validates :name,                    presence: true,
                                        uniqueness: true,
                                        length: { maximum: 50 }
    validates :database_code,           uniqueness: true,
                                        length: { maximum: 4 }
    validates :address,                 length: { maximum: 255 }
  

    def self.import(file, user)
        creates = 0
        updates = 0
        errors = 0
        error_list = []
  
        CSV.foreach(file.path, headers: true) do |fields|
            venue = Venue.find_by_database_code(fields[0].to_s)
            if venue
                venue.active               = fields[1]
                venue.name                 = fields[2]
                venue.address              = fields[3]
                venue.updated_by           = user.id
    
                if venue.save
                    updates += 1
                else
                    errors += 1
                    error_list << venue
                end
            else
                venue = Venue.create(
                    name:                 fields[2],
                    database_code:        fields[0],
                    active:               fields[1],
                    address:              fields[3],
                    updated_by:           user.id)
                if venue.errors.empty?
                    creates += 1
                else
                    errors += 1
                    error_list << venue
                end
            end
        end
  
        { creates: creates, updates: updates, errors: errors, error_list: error_list }
    end

    private

    def self.sync_fields
        ['name',
         'address']
    end
end
