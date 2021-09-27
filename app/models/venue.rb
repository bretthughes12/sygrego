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
                end
            end
        end
  
        { creates: creates, updates: updates, errors: errors }
    end

    private

    def self.sync_fields
        ['name',
         'address']
    end
end
