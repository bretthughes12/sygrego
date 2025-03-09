# == Schema Information
#
# Table name: sports
#
#  id                      :bigint           not null, primary key
#  active                  :boolean          default(TRUE)
#  allow_negative_score    :boolean          default(FALSE)
#  blowout_rule            :boolean          default(FALSE)
#  bonus_for_officials     :boolean          default(FALSE)
#  classification          :string(10)       not null
#  court_name              :string(20)       default("Court")
#  forfeit_score           :integer          default(0)
#  ladder_tie_break        :string(20)       default("Percentage")
#  max_entries_indiv       :integer          default(0), not null
#  max_indiv_entries_group :integer          default(0), not null
#  max_team_entries_group  :integer          default(0), not null
#  name                    :string(20)       not null
#  point_name              :string(20)       default("Point")
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

    require 'roo'

    attr_reader :file
    attr_reader :grades_as_limited

    has_many :grades
    has_many :groups_sports_filters, dependent: :destroy

    scope :individual, -> { where(classification: 'Individual') }
    scope :team, -> { where(classification: 'Team') }
    scope :active, -> { where(active: true) }

    has_one_attached :rules_file

    CLASSIFICATIONS = %w[Individual
                         Team]

    TIE_TYPES = ['Percentage',
                 'Point Difference',
                 'Points For']
  
    validates :name,                    presence: true,
                                        uniqueness: { case_sensitive: false },
                                        length: { maximum: 20 }
    validates :max_indiv_entries_group, presence: true,
                                        numericality: { only_integer: true }
    validates :max_team_entries_group,  presence: true,
                                        numericality: { only_integer: true }
    validates :max_entries_indiv,       presence: true,
                                        numericality: { only_integer: true }
    validates :forfeit_score,           numericality: { only_integer: true }
    validates :classification,          presence: true,
                                        length: { maximum: 10 },
                                        inclusion: { in: CLASSIFICATIONS }
    validates :ladder_tie_break,        presence: true,
                                        length: { maximum: 20 },
                                        inclusion: { in: TIE_TYPES }
    validates :court_name,              length: { maximum: 20 }
    validates :point_name,              length: { maximum: 20 }

    def self.per_page
        15
    end

    def <=>(other)
        name <=> other.name
    end
    
    def max_entries_group
        max_indiv_entries_group + max_team_entries_group
    end

    def group_entries(group)
        grades.to_a.sum do |grade|
          grade.sport_entries.where(['group_id = ?', group.id]).count
        end
    end

    def sport_preferences(group)
        prefs = []
        group.participants.coming.accepted.playing_sport.each do |participant|
            participant.sport_preferences.entered.each do |pref|
                prefs << pref if pref.sport == self
            end
        end
        prefs
    end
    
    def indiv_entries(participant)
        #    entry_count = 0
        #    self.sport_grades.each do |grade|
        #      grade.sport_entries.each do |entry|
        #        if entry.participants.include?(participant)
        #          entry_count += 1
        #        end
        #      end
        #    end
        entry_count = ParticipantsSportEntry.count_by_sql(
          'select count(*) from sport_entries, grades, participants_sport_entries ' \
          'where sport_entries.id = participants_sport_entries.sport_entry_id ' \
          'and sport_entries.grade_id = grades.id ' \
          'and grades.sport_id = ' + id.to_s + ' ' \
          'and participants_sport_entries.participant_id = ' + participant.id.to_s
        )
        entry_count
    end
    
    def limit_grades_to(grades)
        @grades_as_limited = []
        grades.each.collect do |grade|
          @grades_as_limited << grade if grade.sport == self
        end
    end
        
    def self.import_excel(file, user)
        creates = 0
        updates = 0
        errors = 0
        error_list = []
  
        xlsx = Roo::Spreadsheet.open(file)

        xlsx.sheet(xlsx.default_sheet).parse(headers: true).each do |row|
            unless row['Name'] == 'Name'

                sport = Sport.find_by_name(row['Name'].to_s)

                if sport
                    sport.active = row['Active']
                    sport.classification = row['Classification'].to_s
                    sport.max_indiv_entries_group = row['MaxIndivGrp'].to_i
                    sport.max_team_entries_group = row['MaxTeamGrp'].to_i
                    sport.max_entries_indiv = row['MaxIndiv'].to_i
                    sport.bonus_for_officials = row['Bonus']
                    sport.court_name = row['CourtName']
                    sport.blowout_rule = row['BlowoutRule']
                    sport.forfeit_score = row['ForfeitScore'].to_i
                    sport.ladder_tie_break = row['TieBreak']
                    sport.allow_negative_score = row['AllowNeg']
                    sport.point_name = row['PointName']
                    sport.updated_by = user.id
                    if sport.save
                        updates += 1
                    else
                        errors += 1
                        error_list << sport
                    end
                else
                    sport = Sport.create(
                        name:                      row['Name'],
                        active:                    row['Active'],
                        classification:            row['Classification'],
                        max_indiv_entries_group:   row['MaxIndivGrp'].to_i,
                        max_team_entries_group:    row['MaxTeamGrp'].to_i,
                        max_entries_indiv:         row['MaxIndiv'].to_i,
                        bonus_for_officials:       row['Bonus'],
                        court_name:                row['CourtName'],
                        blowout_rule:              row['BlowoutRule'],
                        forfeit_score:             row['ForfeitScore'].to_i,
                        ladder_tie_break:          row['TieBreak'],
                        allow_negative_score:      row['AllowNeg'],
                        point_name:                row['PointName'],
                        updated_by:                user.id)
                    if sport.errors.empty?
                        creates += 1
                    else
                        errors += 1
                        error_list << sport
                    end
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
         'court_name',
         'blowout_rule',
         'forfeit_score',
         'allow_negative_score',
         'ladder_tie_break',
         'point_name']
    end
end
