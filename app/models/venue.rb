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
# Indexes
#
#  index_venues_on_database_code  (database_code) UNIQUE
#  index_venues_on_name           (name) UNIQUE
#

class Venue < ApplicationRecord
    include Auditable
 
    require 'roo'

    has_many :sections

    scope :active, -> { where(active: true) }

    validates :name,                    presence: true,
                                        uniqueness: true,
                                        length: { maximum: 50 }
    validates :database_code,           uniqueness: true,
                                        length: { maximum: 4 }
    validates :address,                 length: { maximum: 255 }
  
    def self.import_excel(file, user)
        creates = 0
        updates = 0
        errors = 0
        error_list = []
  
        xlsx = Roo::Spreadsheet.open(file)

        xlsx.sheet(xlsx.default_sheet).parse(headers: true).each do |row|
            unless row['RowID'] == 'RowID'

                venue = Venue.find_by_database_code(row['RowID'])

                if venue
                    venue.active               = row['Active']
                    venue.name                 = row['Name']
                    venue.address              = row['Address']
                    venue.updated_by           = user.id
        
                    if venue.save
                        updates += 1
                    else
                        errors += 1
                        error_list << venue
                    end
                else
                    venue = Venue.create(
                        name:                 row['Name'],
                        database_code:        row['RowID'],
                        active:               row['Active'],
                        address:              row['Address'],
                        updated_by:           user.id)

                    if venue.errors.empty?
                        creates += 1
                    else
                        errors += 1
                        error_list << venue
                    end
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
