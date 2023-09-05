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
#  one_entry_per_group     :boolean          default(FALSE)
#  over_limit              :boolean          default(FALSE)
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

    has_many :sport_entries, dependent: :destroy
    has_many :sport_preferences, dependent: :destroy
    has_many :groups_grades_filters, dependent: :destroy
    has_many :sections, dependent: :destroy
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
    delegate :classificaion,
             :draw_type, to: :sport

    before_save :update_grade_flags_on_limit_change, if: :will_save_change_to_entry_limit?

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

    def cached_sport_entries
        @sport_entries ||= sport_entries
    end
    
    def venue_name
        venues = possible_venues
        if venues.size == 1
          venues[0].name
        else
          'Multiple venues available'
        end
    end
    
    def venue_id
        venues = possible_venues
        venues[0].id if venues.size == 1
    end
    
    def possible_venues
        @venues ||= sections.collect(&:venue)
        @venues.uniq
    end
    
    def session_name
        sessions = possible_sessions
        if sessions.size == 1
          sessions[0].name
        else
          'Multiple sessions available'
        end
    end
    
    def possible_sessions
        @sessions ||= sections.collect(&:session)
        @sessions.uniq
    end

    def name_with_session
        name + " (#{session_name})"
    end
        
#    def name_with_percentage_full
#        if entry_limit && entry_limit > 0
#          name + " (#{percentage_full}% full)"
#        else
#          name
#        end
#    end
    
#    def percentage_full
#        if entry_limit && entry_limit > 0
#          number_of_teams * 100 / entry_limit
#        else
#          0
#        end
#    end
    
    def entries_entered
        sport_entries.entered
    end
    
    def entries_requested
        sport_entries.requested
    end
    
    def entries_waiting
        sport_entries.waiting_list
    end
    
    def entries_to_be_confirmed
        sport_entries.to_be_confirmed
    end

#    def number_of_teams
#        cached_sport_entries.count
#    end

    def starting_status
        if entry_limit && status == 'Open'
          'Requested'
        else
          if entry_limit &&
             entries_entered.size + entries_requested.size + entries_to_be_confirmed.size >= entry_limit
              'Waiting List'
          else
              'Entered'
          end
        end
    end
    
    def starting_section
        if sections.size == 1
          sections[0]
        else
          start_section = nil
    
          sections.each do |section|
            next unless section.number_in_draw
            if section.sport_entries.size < section.number_in_draw
              start_section = section
              break
            end
          end
    
          start_section
        end
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

    def eligible_to_participate?(participant)
        return false if participant.age && participant.age < min_age
        return false if participant.age && participant.age > max_age
        return false if participant.spectator
        return true if %w[Open Mixed].include?(gender_type)
        return false if gender_type == 'Mens' && participant.gender == 'F'
        return false if gender_type == 'Ladies' && participant.gender == 'M'
        true
    end
    
    def can_accept_entries
        active && 
           (status == 'Open' ||
            entry_limit && sport_entries.count < entry_limit)
    end

#    def sport_entry_ids
#        cached_sport_entries.collect(&:id)
#    end

    def self.reset_all_restricted_entries_to_requested!
        Grade.restricted.each do |g|
            g.sport_entries.each(&:reset!)
        end
    end
    
    def close!
        self.status = 'Closed'
        save(validate: false)
    end

    def coordinators
        coords = []
        sections.each do |s|
          coords += s.volunteers.sport_coords unless s.volunteers.sport_coords.empty?
        end
        coords
    end

    def volunteers
        volunteers = []
        sections.each do |s|
          volunteers += s.volunteers unless s.volunteers.empty?
        end
        volunteers
    end
    
    def coordinators_groups
        groups = coordinators.collect do |c|
          c.participant&.group
        end
        groups.uniq
    end

    def high_priority_entries
        entries = []
        sport_entries.each do |e|
          entries << e if e.high_priority
        end
        entries
    end

    def update_for_change_in_entries(save_record = true)
        self.entries_to_be_allocated = entry_limit.nil? ? 999 : entry_limit - entries_to_be_confirmed.size - entries_entered.size
        self.over_limit = entries_to_be_allocated < entries_requested.size
        self.one_entry_per_group = groups_requested.size >= entries_to_be_allocated
   
        save(validate: false) if save_record
    end
    
    def allocate_requested_entries_by_ballot(allocated, missed_out)
        factors = requested_entry_factors
    
        # The allocation bonus changes from grade to grade, so must
        # be added for each ballot
        factors.each do |e|
          entry = SportEntry.find(e[0])
          factors[e[0]] += entry.group.allocation_bonus
        end
    
        # Do the allocation now
        entries_to_be_allocated.times do
          allocate_random_entry(factors, allocated)
        end
    
        # All entries remaining have not been allocated - hence these
        # are the ones that missed out
        factors.each do |e|
          entry = SportEntry.find(e[0])
          entry.reject!
          missed_out[e[0]] = e[1]
        end
    end
    
    def requested_entry_factors
        factors = {}
        cached_sport_entries.requested.each { |e| factors[e.id] = e.allocation_factor }
        factors
    end
    
    def allocate_random_entry(factors, allocated)
        alloc = rand(factors.values.sum)
    
        total = 0
        factors.each do |e|
          total += e[1]
          next unless total > alloc
          entry = SportEntry.find(e[0])
          entry.require_confirmation!
          entry.assign_section!
          allocated[e[0]] = e[1]
          factors.reject! { |k, _v| k == e[0] }
          break
        end
    end
    
    def set_waiting_list_expiry!
        self.waitlist_expires_at = Time.now + 2.days
        save(validate: false) 
    end
    
    def check_waiting_list_status!
        unless waitlist_expires_at.nil?
          if entries_waiting.size == 0 ||
             entries_entered.size + entries_to_be_confirmed.size == entry_limit
            self.waitlist_expires_at = nil
            save(validate: false) 
          end
        end
    end
    
    def total_courts_available
        if self.sections.empty?
            0
        else
            self.sections.sum(&:courts_available)
        end
    end

    def teams_per_court
        if entry_limit.nil?
            999
        elsif total_courts_available == 0
            0
        else
            (entry_limit / total_courts_available).ceil
        end
    end

#    def expire_wait_list!
#        entries_waiting.each do |entry|
#          entry.destroy
#        end
        
#        self.waitlist_expires_at = nil
#        save(validate: false) 
#    end
    
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

    def groups_requested
        groups = entries_requested.collect(&:group)
        groups.uniq
    end

    def update_grade_flags_on_limit_change
        update_for_change_in_entries(false)
    end

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
