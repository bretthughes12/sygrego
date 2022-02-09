# == Schema Information
#
# Table name: volunteer_types
#
#  id            :integer          not null, primary key
#  name          :string(100)      not null
#  sport_related :boolean          default("false")
#  t_shirt       :boolean          default("false")
#  description   :text
#  database_code :string(4)
#  active        :boolean          default("true")
#  updated_by    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_volunteer_types_on_name  (name) UNIQUE
#

class VolunteerType < ApplicationRecord
    include Comparable
    include Auditable

    require 'csv'

#    has_many :volunteers

    scope :sport_related, -> { where(sport_related: true) }
    scope :non_sport_related, -> { where(sport_related: false) }
    scope :active, -> { where(active: true) }
  
    validates :name, presence: true,
        length: { maximum: 100 }
    validates :database_code, uniqueness: true,
        length: { maximum: 4 }
        
    def self.import(file, user)
        creates = 0
        updates = 0
        errors = 0
        error_list = []
    
        CSV.foreach(file.path, headers: true) do |fields|
            type = VolunteerType.find_by_name(fields[2].to_s)
            if type
                type.active = fields[1]
                type.database_code = fields[0]
                type.sport_related = fields[3]
                type.t_shirt = fields[4]
                type.description = fields[5]
                type.updated_by = user.id
                if type.save
                    updates += 1
                else
                    errors += 1
                    error_list << type
                end
            else
                type = VolunteerType.create(
                    name:                      fields[2],
                    active:                    fields[1],
                    database_code:             fields[0],
                    sport_related:             fields[3],
                    t_shirt:                   fields[4],
                    description:               fields[5],
                    updated_by:                user.id)
                if type.errors.empty?
                    creates += 1
                else
                    errors += 1
                    error_list << type
                end
            end
        end
    
        { creates: creates, updates: updates, errors: errors, error_list: error_list }
    end
    
    private

    def self.sync_fields
        ['name',
         'database_code',
         'sport_related',
         'active']
    end
end
