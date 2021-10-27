# == Schema Information
#
# Table name: grades
#
#  id                      :bigint           not null, primary key
#  active                  :boolean
#  database_rowid          :integer
#  entries_to_be_allocated :integer          default(999)
#  entry_limit             :integer
#  gender_type             :string(10)       default("Open"), not null
#  grade_type              :string(10)       default("Team"), not null
#  max_age                 :integer          default(29), not null
#  max_participants        :integer          default(0), not null
#  min_age                 :integer          default(11), not null
#  min_females             :integer          default(0), not null
#  min_males               :integer          default(0), not null
#  min_participants        :integer          default(0), not null
#  name                    :string(50)       not null
#  one_entry_per_group     :boolean
#  over_limit              :boolean
#  starting_entry_limit    :integer
#  status                  :string(20)       default("Open"), not null
#  team_size               :integer          default(1)
#  updated_by              :bigint
#  waitlist_expires_at     :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  sport_id                :bigint           default(0), not null
#
# Indexes
#
#  index_grades_on_name  (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (sport_id => sports.id)
#
class Grade < ApplicationRecord
    include Comparable
    include Auditable

    require 'csv'
  
    attr_reader :file

#    has_many :officials, as: :coord_rqmt
#    has_many :sport_entries
#    has_many :sport_preferences
#    has_many :groups_sport_grades_filters
    has_many :sections
    belongs_to :sport

    default_scope { order(:name) }
    scope :active, -> { where(active: true) }
    scope :accepting, -> { where(status: 'Open') }
    scope :closed, -> { where(status: 'Closed') }
    scope :restricted, -> { where('entry_limit is not NULL') }
    scope :over_limit, -> { where(over_limit: true) }
    scope :not_over_limit, -> { where(over_limit: false) }
    scope :ballot_for_high_priority, -> { where(one_entry_per_group: true) }
    scope :ballot_for_low_priority, -> { where(one_entry_per_group: false) }
    scope :team, -> { where('sports.classification' => 'Team').includes(:sport) }
    scope :individual, -> { where('sports.classification' => 'Individual').includes(:sport) }

    delegate :name, to: :sport, prefix: true
    delegate :classificaion, to: :sport

    GRADE_TYPES = %w[Singles
        Doubles
        Team].freeze

    GENDER_TYPES = %w[Open
        Mens
        Ladies
        Mixed].freeze

    STATUSES = %w[Open
        Closed
        Allocated].freeze

    validates :sport_id,               presence: true
    validates :name,                   presence: true,
                                       uniqueness: { case_sensitive: false },
                                       length: { maximum: 50 }
    validates :grade_type,             presence: true,
                                       length: { maximum: 10 },
                                       inclusion: { in: GRADE_TYPES,
                                       message: "should be one of: 'Singles'; 'Doubles'; and 'Team'" }
    validates :max_age,                presence: true,
                                       numericality: { only_integer: true },
                                       inclusion: { in: 0..130,
                                       message: 'should be between 0 and 130' }
    validates :min_age,                presence: true,
                                       numericality: { only_integer: true },
                                       inclusion: { in: 0..130,
                                       message: 'should be between 0 and 130' }
    validates :gender_type,            presence: true,
                                       length: { maximum: 10 },
                                       inclusion: { in: GENDER_TYPES,
                                       message: "should be one of: 'Open'; 'Mens'; 'Ladies'; and 'Mixed'" }
    validates :max_participants,       presence: true,
                                       numericality: { only_integer: true }
    validates :min_participants,       presence: true,
                                       numericality: { only_integer: true }
    validates :min_males,              presence: true,
                                       numericality: { only_integer: true }
    validates :min_females,            presence: true,
                                       numericality: { only_integer: true }
    validates :entry_limit,            numericality: { only_integer: true },
                                       allow_blank: true
    validates :starting_entry_limit,   numericality: { only_integer: true },
                                       allow_blank: true
    validates :status,                 presence: true,
                                       length: { maximum: 20 },
                                       inclusion: { in: STATUSES }

    def <=>(other)
        name <=> other.name
    end

    def venue_name
        venues = possible_venues
        if venues.size == 1
          venues[0].name
        else
          '(not final)'
        end
    end
    
    def venue_id
        venues = possible_venues
        venues[0].id if venues.size == 1
    end
    
    def possible_venues
        venues = sections.collect(&:venue)
        venues.uniq
    end
    
    def possible_sessions
        sessions = sections.collect(&:session)
        sessions.uniq
    end
    
    def max_entries_group
        if grade_type == 'Singles'
            sport.max_indiv_entries_group
        elsif grade_type == 'Doubles'
            sport.max_indiv_entries_group
        elsif grade_type == 'Team'
            sport.max_team_entries_group
        else
            0
        end
    end

    def close!
        self.status = 'Closed'
        save(validate: false)
    end

    def self.import(file, user)
        creates = 0
        updates = 0
        errors = 0
        error_list = []
  
        CSV.foreach(file.path, headers: true) do |fields|
            limit = fields[14].to_i == 0 ? nil : fields[14].to_i
            start_limit = fields[15].to_i == 0 ? nil : fields[15].to_i
            sport = Sport.where(name: fields[1]).first

            grade = Grade.find_by_name(fields[2].to_s)
            if grade
                grade.database_rowid          = fields[0].to_i
                grade.sport                   = sport
                grade.name                    = fields[2]
                grade.active                  = true
                grade.grade_type              = fields[4]
                grade.status                  = fields[5]
                grade.max_age                 = fields[6].to_i
                grade.min_age                 = fields[7].to_i
                grade.gender_type             = fields[8]
                grade.max_participants        = fields[9].to_i
                grade.min_participants        = fields[10].to_i
                grade.min_males               = fields[11].to_i
                grade.min_females             = fields[12].to_i
                grade.team_size               = fields[13].to_i
                grade.entry_limit             = limit
                grade.starting_entry_limit    = start_limit
                grade.updated_by = user.id
 
                if grade.save
                    updates += 1
                else
                    errors += 1
                    error_list << grade
                end
            else
                grade = Grade.create(
                   database_rowid:          fields[0],
                   sport:                   sport,
                   name:                    fields[2],
                   active:                  true,
                   grade_type:              fields[4],
                   status:                  fields[5],
                   max_age:                 fields[6].to_i,
                   min_age:                 fields[7].to_i,
                   gender_type:             fields[8],
                   max_participants:        fields[9].to_i,
                   min_participants:        fields[10].to_i,
                   min_males:               fields[11].to_i,
                   min_females:             fields[12].to_i,
                   team_size:               fields[13].to_i,
                   entry_limit:             limit,
                   starting_entry_limit:    start_limit,
                   updated_by:              user.id)

                if grade.errors.empty?
                    creates += 1
                else
                    errors += 1
                    error_list << grade
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
         'entry_limit',
         'gender_type',
         'grade_type',
         'max_age',
         'min_age',
         'max_participants',
         'min_participants',
         'sport_id',
         'status'
        ]
    end
end
