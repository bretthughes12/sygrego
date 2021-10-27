# == Schema Information
#
# Table name: sports
#
#  id                      :bigint           not null, primary key
#  active                  :boolean          default(TRUE)
#  bonus_for_officials     :boolean          default(FALSE)
#  classification          :string(10)       not null
#  court_name              :string(20)       default("Court")
#  draw_type               :string(20)       not null
#  max_entries_indiv       :integer          default(0), not null
#  max_indiv_entries_group :integer          default(0), not null
#  max_team_entries_group  :integer          default(0), not null
#  name                    :string(20)       not null
#  updated_by              :bigint
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_sports_on_name  (name) UNIQUE
#
class Sport < ApplicationRecord
    include Comparable
    include Auditable

    has_many :grades
#    has_many :officials, as: :coord_rqmt
#    has_many :downloads

    attr_reader :grades_as_limited

    scope :individual, -> { where(classification: 'Individual') }
    scope :team, -> { where(classification: 'Team') }
    scope :active, -> { where(active: true) }

    CLASSIFICATIONS = %w[Individual
                         Team]

    DRAW_TYPES = ['Knockout',
                  'Open',
                  'Round Robin']

    validates :name,                    presence: true,
                                        uniqueness: { case_sensitive: false },
                                        length: { maximum: 20 }
    validates :max_indiv_entries_group, presence: true,
                                        numericality: { only_integer: true }
    validates :max_team_entries_group,  presence: true,
                                        numericality: { only_integer: true }
    validates :max_entries_indiv,       presence: true,
                                        numericality: { only_integer: true }
    validates :classification,          presence: true,
                                        length: { maximum: 10 },
                                        inclusion: { in: CLASSIFICATIONS }
    validates :draw_type,               presence: true,
                                        length: { maximum: 20 },
                                        inclusion: { in: DRAW_TYPES }
    validates :court_name,              length: { maximum: 20 }

    def self.per_page
        15
    end

    def <=>(other)
        name <=> other.name
    end
    
    def max_entries_group
        max_indiv_entries_group + max_team_entries_group
    end

    def limit_grades_to(grades)
        @grades_as_limited = []
        grades.each.collect do |grade|
          @grades_as_limited << grade if grade.sport == self
        end
    end
        
    def self.import(file, user)
        creates = 0
        updates = 0
        errors = 0
        error_list = []
  
        CSV.foreach(file.path, headers: true) do |fields|
            sport = Sport.find_by_name(fields[0].to_s)
            if sport
                sport.active = fields[1]
                sport.classification = fields[2].to_s
                sport.max_indiv_entries_group = fields[3].to_i
                sport.max_team_entries_group = fields[4].to_i
                sport.max_entries_indiv = fields[5].to_i
                sport.bonus_for_officials = fields[6]
                sport.court_name = fields[7]
                sport.draw_type = fields[8]
                sport.updated_by = user.id
                if sport.save
                    updates += 1
                else
                    errors += 1
                    error_list << sport
                end
            else
                sport = Sport.create(
                    name:                      fields[0],
                    active:                    fields[1],
                    classification:            fields[2],
                    draw_type:                 fields[8],
                    max_indiv_entries_group:   fields[3].to_i,
                    max_team_entries_group:    fields[4].to_i,
                    max_entries_indiv:         fields[5].to_i,
                    bonus_for_officials:       fields[6],
                    court_name:                fields[7],
                    updated_by:                user.id)
                if sport.errors.empty?
                    creates += 1
                else
                    errors += 1
                    error_list << sport
                end
            end
        end
  
        { creates: creates, updates: updates, errors: errors, error_list: error_list }
    end
  
    private

    def self.sync_fields
        ['name',
         'classification',
         'max_entries_indiv',
         'max_indiv_entries_group',
         'max_team_entries_group',
         'court_name']
    end
end
