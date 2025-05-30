# == Schema Information
#
# Table name: sections
#
#  id               :bigint           not null, primary key
#  active           :boolean
#  database_rowid   :integer
#  draw_type        :string(20)       default("Round Robin"), not null
#  finals_format    :string(20)
#  name             :string(50)       not null
#  number_in_draw   :integer
#  number_of_courts :integer          default(1)
#  number_of_groups :integer          default(1)
#  results_locked   :boolean          default(FALSE)
#  start_court      :integer          default(1)
#  updated_by       :bigint
#  year_introduced  :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  grade_id         :bigint           default(0), not null
#  session_id       :bigint           default(0), not null
#  venue_id         :bigint           default(0), not null
#
# Indexes
#
#  index_sections_on_name  (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (grade_id => grades.id)
#  fk_rails_...  (session_id => sessions.id)
#  fk_rails_...  (venue_id => venues.id)
#

class Section < ApplicationRecord
    include Comparable
    include Auditable

    require 'pp'
  
    attr_reader :file

    has_and_belongs_to_many :volunteers
    has_many :sport_entries, dependent: :destroy
    has_many :preferred_entries, class_name: 'SportEntry'
    has_many :round_robin_matches, dependent: :destroy
    belongs_to :grade
    belongs_to :venue
    belongs_to :session
  
    scope :active, -> { where(active: true) }
    scope :round_robin, -> { where(draw_type: "Round Robin") }
  
    has_one_attached :draw_file

    delegate :name, to: :venue, prefix: 'venue'
    delegate :name, to: :session, prefix: 'session'
    delegate :sport_name, :sport, to: :grade
  
    DRAW_TYPES = ['Knockout',
                  'Open',
                  'Round Robin',
                  'Quad Round Robin',
                  '5 x Round Robin'
    ]

    FINALS_FORMATS = [
        'Top 2',
        'Top 2 in Group',
        'Top 4',
        'Top in Group'
    ]

    validates :name,                   presence: true,
                                       uniqueness: true,
                                       length: { maximum: 50 }
    validates :grade_id,               presence: true
    validates :venue_id,               presence: true
    validates :session_id,             presence: true
    validates :number_in_draw,         numericality: true,
                                       allow_blank: true
    validates :number_of_courts,       numericality: true,
                                       allow_blank: true
    validates :year_introduced,        numericality: true,
                                       allow_blank: true
    validates :draw_type,              presence: true,
                                       length: { maximum: 20 },
                                       inclusion: { in: DRAW_TYPES }
 
    def <=>(other)
      name <=> other.name if other
    end

    def level
        match = name.match(/Level (\d)/)
        if match
            "Level #{match[1].to_i}"
        elsif name.match(/Under 18/)
            "Level 4"
        elsif name.match(/Under 15/)
            "Level 5"
        else
            "Open"
        end
    end

    def competitiveness
        if name.match(/Competitive/)
            "Competitive"
        elsif name.match(/Social/)
            "Social"
        else
            ""
        end
    end

    def section
        match = name.match(/Section (\d)/)
        if match
            "Section #{match[1].to_i}"
        else
            ""
        end
    end

    def sport_coords
        volunteers.sport_coords
    end
    
    def number_of_teams
        sport_entries.not_waiting.count
    end
    
    def session_and_venue
        session.name + " - " + venue.name
    end

    def name_with_session
        name + " (#{session_name})"
    end
    
    def last_result
        round_robin_matches.last
    end

    def submitted?
        last_result && last_result.match == 200 && last_result.complete? ? true : false
    end

    def started?
        round_robin_matches.each do |sre|
            return true if sre.complete?
        end

        false
    end

    def can_take_more_entries?
        self.sport_entries.count < teams_allowed
    end

    def entries_allowed_to_be_moved
        entries = []

        sport_entries.each do |entry|
            coord_groups = sport_coords.collect(&:group).flatten
            entries << entry unless coord_groups.include?(entry.group)
        end

        entries.shuffle!
    end

    def courts_available
        return number_of_courts unless number_of_courts.blank? || number_of_courts == 0
        return 1
    end

    def teams_allowed
        if grade.status == 'Allocated'
            number_in_draw
        elsif grade.sections.count == 1 && !grade.entry_limit.nil?
            grade.entry_limit
        elsif number_of_courts.blank? || number_of_courts == 0
            grade.teams_per_court
        else    
            grade.teams_per_court * number_of_courts
        end
    end

    def access_draw_type
        self.draw_type[0]
    end
    
    def add_finals_from_ladder(ladder)
        # 1 v 2 straight to grand final (only 1 group)
        if finals_format == 'Top 2'
        RoundRobinMatch.create(
            section_id: id,
            court: ladder.start_court,
            match: 200,
            entry_a_id: ladder.nth_in_group(1, 1),
            entry_b_id: ladder.nth_in_group(1, 2)
        )
        # 1 v 4 and 2 v 3 to semi finals (only 1 group)
        elsif finals_format == 'Top 4'
        RoundRobinMatch.create(
            section_id: id,
            court: ladder.start_court,
            match: 100,
            entry_a_id: ladder.nth_in_group(1, 1),
            entry_b_id: ladder.nth_in_group(1, 4)
        )
        RoundRobinMatch.create(
            section_id: id,
            court: ladder.second_court,
            match: 101,
            entry_a_id: ladder.nth_in_group(1, 2),
            entry_b_id: ladder.nth_in_group(1, 3)
        )
        # 1 v 2 of opposing groups to semi finals (2 groups)
        elsif finals_format == 'Top 2 in Group'
        RoundRobinMatch.create(
            section_id: id,
            court: ladder.start_court,
            match: 100,
            entry_a_id: ladder.nth_in_group(1, 1),
            entry_b_id: ladder.nth_in_group(2, 2)
        )
        RoundRobinMatch.create(
            section_id: id,
            court: ladder.second_court,
            match: 101,
            entry_a_id: ladder.nth_in_group(2, 1),
            entry_b_id: ladder.nth_in_group(1, 2)
        )
        elsif finals_format == 'Top in Group' && number_of_groups == 3
        # Top from each group, and next best (3 groups)
        RoundRobinMatch.create(
            section_id: id,
            court: ladder.start_court,
            match: 100,
            entry_a_id: ladder.nth_in_group(1, 1),
            entry_b_id: ladder.nth_in_group(3, 1)
        )
        RoundRobinMatch.create(
            section_id: id,
            court: ladder.second_court,
            match: 101,
            entry_a_id: ladder.nth_in_group(2, 1),
            entry_b_id: ladder.next_best
        )
        else # section.finals_format == 'Top in Group' && section.number_of_groups == 4
        # Top from each group (4 groups)
        RoundRobinMatch.create(
            section_id: id,
            court: ladder.start_court,
            match: 100,
            entry_a_id: ladder.nth_in_group(1, 1),
            entry_b_id: ladder.nth_in_group(3, 1)
        )
        RoundRobinMatch.create(
            section_id: id,
            court: ladder.second_court,
            match: 101,
            entry_a_id: ladder.nth_in_group(2, 1),
            entry_b_id: ladder.nth_in_group(4, 1)
        )
        end
    end

    def add_finalists_from_semis
        # winners of each semi play in finals
        s1 = round_robin_matches.where(match: 100).first
        s2 = round_robin_matches.where(match: 101).first

        if s1.score_a > s1.score_b
            w1 = s1.entry_a_id
        else
            w1 = s1.entry_b_id
        end

        if s2.score_a > s2.score_b
            w2 = s2.entry_a_id
        else
            w2 = s2.entry_b_id
        end

        RoundRobinMatch.create(
            section_id: id,
            court: start_court,
            match: 200,
            entry_a_id: w1,
            entry_b_id: w2
        )
    end

    def reset_round_robin_draw!
        round_robin_matches.all.each do |match|
            if match.match > 99
                match.delete
            else 
                match.score_a = 0
                match.forfeit_a = false
                match.score_b = 0
                match.forfeit_b = false
                match.complete = false
                match.save(validate: false)
            end
        end
    end

    def lock_results!
        self.results_locked = true
        self.save(validate: false)
    end

#    def self.round_robin
#        sections = []

#        Section.active.order(:name).includes(:grade).all.each do |section|
#            sections << section if section.grade.sport.draw_type == 'Round Robin'
#        end

#        sections
#    end

    def self.without_sc
        sections = []
        Section.active.order(:name).each do |section|
            sections << section if section.sport_coords.empty?
        end
        sections
    end

    def self.too_many_entries_same_group
        sections = []
        Section.active.order(:name).each do |section|
            if section.grade.sections.count > 1
                section.sport_entries.select(:group_id).group(:group_id).count.each do |key,value|
                    sections << section if value > 2
                end
            end
        end
        sections.uniq
    end

    def self.over_limit
        sections = []
        Section.active.order(:name).each do |section|
            sections << section if section.sport_entries.count > section.teams_allowed
        end
        sections
    end

    def self.low_numbers
        sections = []
        Section.active.order(:name).each do |section|
            sections << section if section.sport_entries.count < 4
        end
        sections
    end

    def self.import_excel(file, user)
        creates = 0
        updates = 0
        errors = 0
        error_list = []
  
        xlsx = Roo::Spreadsheet.open(file)

        xlsx.sheet(xlsx.default_sheet).parse(headers: true).each do |row|
            unless row['RowID'] == 'RowID'

                grade = Grade.where(name: row['Grade']).first
                venue = Venue.where(database_code: row['Venue']).first
                session = Session.where(database_rowid: row['Session'].to_i).first
        
                section = Section.find_by_database_rowid(row['RowID'].to_i) unless row['RowID'] == '0'
                section = Section.find_by_name(row['Name'].to_s) if section.nil?

                if section
                    section.database_rowid          = row['RowID'].to_i
                    section.grade                   = grade
                    section.name                    = row['Name']
                    section.active                  = row['Active']
                    section.venue                   = venue
                    section.year_introduced         = row['YearIntroduced'].to_i
                    section.number_of_courts        = row['NbrOfCourts'].to_i
                    section.session                 = session
                    section.finals_format           = row['FinalsFormat']
                    section.number_of_groups        = row['Groups'].to_i
                    section.start_court             = row['StartCourt'].to_i
                    section.number_in_draw          = row['NbrInDraw'].to_i
                    section.draw_type               = row['DrawType']
                    section.updated_by              = user.id
     
                    if section.save
                        updates += 1
                    else
                        errors += 1
                        error_list << section
                    end
                else
                    section = Section.create(
                       database_rowid:          row['RowID'],
                       grade:                   grade,
                       name:                    row['Name'],
                       active:                  row['Active'],
                       venue:                   venue,
                       year_introduced:         row['YearIntroduced'].to_i,
                       number_of_courts:        row['NbrOfCourts'].to_i,
                       session:                 session,
                       finals_format:           row['FinalsFormat'],
                       number_of_groups:        row['Groups'].to_i,
                       start_court:             row['StartCourt'].to_i,
                       number_in_draw:          row['NbrInDraw'].to_i,
                       draw_type:               row['DrawType'],
                       updated_by:              user.id)
    
                    if section.errors.empty?
                        creates += 1
                    else
                        errors += 1
                        error_list << section
                    end
                end
            end
        end
  
        { creates: creates, updates: updates, errors: errors, error_list: error_list }
    end

  private

    def self.sync_fields
        ['name',
         'active',
         'database_rowid',
         'number_of_courts',
         'finals_format',
         'number_in_draw',
         'number_of_groups',
         'start_court',
         'draw_type',
         'grade_id',
         'session_id',
         'venue_id'
        ]
    end
end
