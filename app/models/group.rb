# == Schema Information
#
# Table name: groups
#
#  id                       :bigint           not null, primary key
#  abbr                     :string(4)        not null
#  address                  :string(200)      not null
#  admin_use                :boolean          default(FALSE)
#  age_demographic          :string(40)
#  allocation_bonus         :integer          default(0)
#  attendee_profile         :text
#  coming                   :boolean          default(TRUE)
#  database_rowid           :integer
#  denomination             :string(40)       not null
#  email                    :string(100)
#  gc_decision              :text
#  gc_role                  :text
#  gc_thoughts              :text
#  gc_years_attended_church :integer
#  group_changes            :text
#  group_focus              :string(100)
#  last_year                :boolean          default(FALSE)
#  late_fees                :decimal(8, 2)    default(0.0)
#  lock_version             :integer          default(0)
#  ministry_goal            :text
#  name                     :string(100)      not null
#  new_group                :boolean          default(TRUE)
#  phone_number             :string(20)
#  postcode                 :integer          not null
#  reference_caller         :string(20)
#  reference_notes          :text
#  short_name               :string(50)       not null
#  status                   :string(12)       default("Stale")
#  suburb                   :string(40)       not null
#  ticket_email             :string(100)
#  ticket_preference        :string(20)       default("Send to GC")
#  trading_name             :string(100)      not null
#  updated_by               :bigint
#  website                  :string(100)
#  years_attended           :integer          default(0)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
# Indexes
#
#  index_groups_on_abbr          (abbr) UNIQUE
#  index_groups_on_name          (name) UNIQUE
#  index_groups_on_short_name    (short_name) UNIQUE
#  index_groups_on_trading_name  (trading_name) UNIQUE
#

class Group < ApplicationRecord
    include Auditable
    include Searchable

    attr_reader :file

    has_many :participants
    has_many :payments
    has_many :sport_entries
    has_many :vouchers
    has_many :group_extras
    has_many :groups_sports_filters, dependent: :destroy
    has_many :group_fee_categories
    has_many :questions
    has_and_belongs_to_many :users
    has_one :event_detail, dependent: :destroy
    has_one :mysyg_setting, dependent: :destroy
    has_one :rego_checklist, dependent: :destroy

    scope :stale, -> { where(status: 'Stale') }
    scope :not_stale, -> { where("status != 'Stale'") }
    scope :submitted, -> { where(status: 'Submitted') }
    scope :coming, -> { where(coming: true) }
    scope :not_coming, -> { where(coming: false) }
    scope :last_year, -> { where(last_year: true) }
    scope :with_bonus, -> { where('allocation_bonus > 0') }
    scope :new_group, -> { where(new_group: true) }
    scope :is_admin, -> { where(admin_use: true) }
    scope :not_admin, -> { where(admin_use: false) }
    scope :sat_early_service, -> { where('event_details.service_pref_sat': '7:00pm').includes(:event_detail) }
    scope :sat_late_service, -> { where('event_details.service_pref_sat': '8:45pm').includes(:event_detail) }
    scope :sat_no_pref_service, -> { where('event_details.service_pref_sat': 'No preference').includes(:event_detail) }
    scope :sun_early_service, -> { where('event_details.service_pref_sun': '7:00pm').includes(:event_detail) }
    scope :sun_late_service, -> { where('event_details.service_pref_sun': '8:45pm').includes(:event_detail) }
    scope :sun_no_pref_service, -> { where('event_details.service_pref_sun': 'No preference').includes(:event_detail) }

    has_one_attached :booklet_file
    has_one_attached :results_file
    has_one_attached :invoice1_file
    has_one_attached :invoice2_file
    has_one_attached :invoice3_file

    delegate :estimated_numbers,
      :warden_zone,
      :onsite, to: :event_detail
    delegate :mysyg_name,
      :show_group_extras_in_mysyg,
      :show_finance_in_mysyg,
      :show_sports_in_mysyg,
      :show_volunteers_in_mysyg,
      :extra_fee_total,
      :extra_fee_per_day,
      :participant_instructions, to: :mysyg_setting

    AGE_DEMOGRAPHIC = ['Early high school, Years 7-9',
                       'Senior high school, Years 10-12',
                       'Young adults, aged 18 to 24',
                       'Young adults, aged 25 +'].freeze

    GROUP_FOCUS = ['Intentional discipleship of current faith community',
                   'Inviting people to engage with a faith community',
                   'Creating a memorable group experience'].freeze

    STATUS = %w[Stale
                Submitted
                Approved].freeze

    TICKET_PREFERENCES = ['Send to GC',
                          'Send to Participant',
                          'Send to Ticket Email'].freeze
  
    validates :abbr,                presence: true,
                                    uniqueness: true,
                                    length: { in: 2..4 }
    validates :name,                presence: true,
                                    uniqueness: true,
                                    length: { maximum: 100 }
    validates :short_name,          presence: true,
                                    uniqueness: true,
                                    length: { maximum: 50 }
    validates :trading_name,        presence: true,
                                    uniqueness: true,
                                    length: { maximum: 100 }
    validates :denomination,        presence: true,
                                    length: { maximum: 40 }
    validates :address,             presence: true,
                                    length: { maximum: 200 }
    validates :suburb,              presence: true,
                                    length: { maximum: 40 }
    validates :postcode,            presence: true,
                                    numericality: { only_integer: true }
    validates :phone_number,        length: { maximum: 20 }
    validates :reference_caller,    length: { maximum: 20 }
    validates :status,              length: { maximum: 12 },
                                    inclusion: { in: STATUS }
    validates :ticket_preference,   length: { maximum: 20 },
                                    inclusion: { in: TICKET_PREFERENCES }
    validates :email,               format: { with: URI::MailTo::EMAIL_REGEXP, message: 'invalid format' },
                                    allow_blank: true,
                                    unless: proc { |o| o.email.blank? }
    validates :ticket_email,        format: { with: URI::MailTo::EMAIL_REGEXP, message: 'invalid format' },
                                    allow_blank: true,
                                    unless: proc { |o| o.ticket_email.blank? }
    validates :allocation_bonus,    numericality: { only_integer: true },
                                    allow_blank: true
    validates :late_fees,           numericality: true,
                                    allow_blank: true
    validates :reference_caller,    length: { maximum: 20 }
    validates :group_focus,        length: { maximum: 100 }
    validates :website,             length: { maximum: 100 }

    searchable_by :abbr, :name, :short_name, :trading_name

    before_save :uppercase_abbr!
    before_save :check_mysyg_name
    after_commit :create_event_details!
    after_commit :create_mysyg_setting!
    after_commit :create_rego_checklist!

    def <=>(other)
      name <=> other.name
    end

    def short_name_with_status
      case 
      when status == 'Stale'
        short_name + ' (Stale)'
        
      when !coming
        short_name + ' (Not coming)'
        
      else
        short_name
      end
    end

    def cached_sport_entries
      @sport_entries ||= sport_entries
    end
      
    def division
      players = participants.coming.accepted.playing_sport.size
      settings = Setting.first
  
      if players <= settings.small_division_ceiling
        'Small Churches'
      elsif players <= settings.medium_division_ceiling
        'Medium Churches'
      else
        'Large Churches'
      end
    end
  
    def self.divisions
      h = {}
      Group.coming.each do |group|
        div = group.division
        a = h[div] || 0
        a += 1
        h[div] = a
      end
      h
    end
  
    def self.group_divisions
      h = {}
      Group.coming.each do |group|
        h[group.id] = group.division
      end
      h
    end
  
    def self.default_group
        Group.find_by_abbr('DFLT')
    end

    def active
      !users.not_stale.empty?
    end
  
    def active_users
      users.not_stale
    end
      
    def church_reps
      church_reps = []
      active_users.each do |u|
        church_reps << u if u.role?(:church_rep) 
      end
      church_reps
    end

    def church_rep
      @church_rep ||= church_reps.first
    end

    def church_rep_name
      church_rep.nil? ? '' : church_rep.name
    end

    def church_rep_email
      church_rep.nil? ? '' : church_rep.email
    end

    def church_rep_phone_number
      church_rep.nil? ? '' : church_rep.phone_number
    end

    def church_rep_wwcc
      church_rep.nil? ? '' : church_rep.wwcc_number
    end

    def gcs
      gcs = []
      active_users.each do |u|
        gcs << u if u.role?(:gc)
      end
      gcs
    end

    def gc
      @gc ||= gcs.first
    end

    def gc_name
      if self.users.primary.empty?
        gc.nil? ? '' : gc.name
      else
        self.users.primary.first.name
      end
    end

    def gc_email
      if self.users.primary.empty?
        gc.nil? ? '' : gc.email
      else
        self.users.primary.first.email
      end
    end

    def gc_phone_number
      if self.users.primary.empty?
        gc.nil? ? '' : gc.phone_number
      else
        self.users.primary.first.phone_number
      end
    end

    def gc_wwcc
      if self.users.primary.empty?
        gc.nil? ? '' : gc.wwcc_number
      else
        self.users.primary.first.wwcc_number
      end
    end

    def ticket_recipient_text
      if self.ticket_preference == 'Send to Participant'
        'each participant'
      elsif self.ticket_preference == 'Send to Ticket Email'
        if self.ticket_email.blank?
          gc_email
        else
          self.ticket_email
        end
      else
        self.gc_email
      end
    end

    def email_recipients
      gcs.collect(&:email)
    end

    def mysyg_status
      if mysyg_setting.mysyg_open
        'Open'
      elsif mysyg_setting.mysyg_enabled
        'Enabled'
      else
        'Not enabled'
      end
    end

    def mysyg_selection_name
      "#{abbr} - #{name}"
    end
  
    def self.mysyg_actives
      active_groups = []
      Group.order(:name).each do |group|
        active_groups << group if group.active && group.mysyg_setting.mysyg_open
      end
      active_groups
    end
  
  def volunteers
    this_group_volunteers = []
    participants.includes(:volunteers).each do |participant|
      unless participant.volunteers.empty?
        this_group_volunteers += participant.volunteers
      end
    end
    this_group_volunteers
  end

  def sport_coords
    this_group_volunteers = []
    participants.includes(:volunteers).each do |participant|
      unless participant.volunteers.sport_coords.empty?
        this_group_volunteers += participant.volunteers.sport_coords
      end
    end
    this_group_volunteers
  end

  def volunteers_required
    return 0 if new_group
    (participants.accepted.coming.count / 5).to_i
  end

  def drivers_all_electronic?
    participants.coming.accepted.drivers.each do |p|
      return false if !p.driver_signature || p.number_plate.blank?
    end
    return true
  end

  def warden_zone_name
    warden_zone.nil? ? '' : warden_zone.name
  end

  def warden_info
    warden_zone.nil? ? '' : warden_zone.warden_info
  end

  def entries_requiring_participants
    entries = []
    cached_sport_entries.each do |entry|
      entries << entry if entry.requires_participants?
    end
    entries
  end

  def entries_requiring_females
    entries = []
    cached_sport_entries.each do |entry|
      entries << entry if entry.requires_females?
    end
    entries
  end

  def entries_requiring_males
    entries = []
    cached_sport_entries.each do |entry|
      entries << entry if entry.requires_males?
    end
    entries
  end

  def first_entry_in_grade(grade)
    cached_sport_entries.select { |entry| entry.grade == grade }.first
  end

  def first_available_entry_in_sport(sport, participant)
    cached_sport_entries.each do |entry| 
      if entry.sport == sport && participant.available_sport_entries.include?(entry)
        return entry
      end
    end
    return nil
  end

  def participant_extras
    participants.coming.accepted.order(:surname, :first_name).collect do |p|
      p.participant_extras
      .wanted
      .includes(:group_extra)
      .order('group_extras.name')
    end.flatten
  end

    def reset_allocation_bonus!
        self.allocation_bonus = 0
        save(validate: false)
    end

    def increment_allocation_bonus!
      settings = Setting.first
      self.allocation_bonus += settings.missed_out_sports_allocation_factor
      save(validate: false)
    end
  
    # Deposit is based on the expected numbers, not the actual numbers
    def deposit
      if admin_use
        0
      elsif estimated_numbers < 20
        150
      elsif estimated_numbers < 40
        300
      else
        600
      end
    end

    def fees
      @fees ||= calculated_fees
    end

    def calculated_fees
      fee = calculated_fee_total

      if fee < deposit
        0
      else
        fee - deposit
      end
    end

    def calculated_fee_total
      participants.to_be_charged.to_a.sum(&:fee)
    end

    def amount_paid
      @amount_paid ||= calculated_amount_paid
    end
  
    def calculated_amount_paid
      payments.paid.to_a.sum(&:amount)
    end
  
    def total_amount_payable
      fees + deposit + nz(late_fees)
    end
  
    def amount_outstanding
      total_amount_payable - amount_paid
    end
  
    def sports_participants_for_grade(grade)
      players = []
      participants.order('surname, first_name').each do |participant|
        next unless participant.coming &&
                    participant.status == 'Accepted' &&
                    !participant.spectator? &&
                    participant.age <= grade.max_age &&
                    participant.age >= grade.min_age &&
                    participant.can_play_sport(grade.sport)
        if gender_matches_gender_type(participant.gender, grade.gender_type)
          players << participant
        end
      end
      players
    end
  
    def grades_available(include_all = false)
      grades_available = []
      grades = Grade.active.order('sport_id, name').includes(:sport).load
  
      grades.each do |grade|
        next unless include_all || grade.can_accept_entries
        next unless grade_type_entries(grade.sport, grade.grade_type) <
                    grade.max_entries_group
        next unless grade_type_entries_in_grade(grade, grade.grade_type) <
                    grade.max_entries_group_in_grade
        grades_available << grade
      end
  
      grades_available
    end
  
    def sections_available
      sections_available = []
      grades = Grade.active.order('sport_id, name').includes(:sport).load
  
      grades.each do |grade|
        next unless grade.can_accept_entries
        next unless grade_type_entries(grade.sport, grade.grade_type) <
                    grade.max_entries_group
        next unless grade_type_entries_in_grade(grade, grade.grade_type) <
                    grade.max_entries_group_in_grade

        grade.sections.active.each do |section|
          next unless section.can_take_more_entries?

          sections_available << section
        end
      end
  
      sections_available
    end
  
    def participants_allowed_per_session 
      [estimated_numbers, participants.size].max * 1.5    
    end
  
    def grades
      cached_sport_entries.each.collect(&:grade).uniq
    end
  
    def sports
      cached_sport_entries.each.collect(&:sport).uniq.sort
    end
  
    def sports_available(include_all)
      grades_available(include_all).collect(&:sport).uniq
    end
  
    def filtered_sports
      filtered_team_sports + filtered_indiv_sports
    end
  
    def filtered_team_sports
      if mysyg_setting.team_sport_view_strategy == 'Show none'
        []
      elsif mysyg_setting.team_sport_view_strategy == 'Show sport entries only'
        sports & Sport.team.load
      elsif mysyg_setting.team_sport_view_strategy == 'Show listed'
        Sport.team.load - sport_filters
      else
        Sport.team.load
      end
    end
  
    def filtered_indiv_sports
      if mysyg_setting.indiv_sport_view_strategy == 'Show none'
        []
      elsif mysyg_setting.indiv_sport_view_strategy == 'Show sport entries only'
        sports & Sport.individual.load
      elsif mysyg_setting.indiv_sport_view_strategy == 'Show listed'
        Sport.individual.load - sport_filters
      else
        Sport.individual.load
      end
    end
  
    def sport_filters
      groups_sports_filters.each.collect(&:sport)
    end
  
    def number_playing_sport
      @number_playing_sport ||= participants.playing_sport.coming.accepted.size
    end
  
    def under_18s_playing_sport
      @under_18s_playing_sport ||= participants.under_18s.playing_sport.coming.accepted.size
    end
  
    def participants_needed_for_session(session)
      number_of_participants = 0
      cached_sport_entries.not_waiting.includes(:section).each do |e|
        number_of_participants += e.team_size if e.section && e.section.session.id == session
      end
      number_of_participants
    end
  
    def under_18s_needed_for_session(session)
      number_of_participants = 0
      cached_sport_entries.not_waiting.includes(:section).each do |e|
        number_of_participants += e.min_under_18s if e.section && e.section.session.id == session
      end
      number_of_participants
    end
  
    def coordinators_allowed
      2
    end

    def helpers_allowed
      (participants.coming.accepted.size / 5).to_i
    end
  
    def helpers
      participants.coming.accepted.helpers
    end

    def free_helpers
      if participants.coming.accepted.playing_sport.size <= 20
        2
      elsif participants.coming.accepted.playing_sport.size <= 40
        4
      elsif participants.coming.accepted.playing_sport.size <= 80
        6
      else
        8
      end
    end

    def males
      participants.coming.accepted.where("gender IN ('M', 'm')").count
    end

    def females
      participants.coming.accepted.where("gender IN ('F', 'f')").count
    end

    def gender_neutral
      participants.coming.accepted.where("gender IN ('U', 'u')").count
    end

    def update_team_numbers(grade)
      entries = cached_sport_entries.where(['grade_id = ?', grade.id])
                                    .order(:id).load
      multi_flag = entries.size > 1
      team_number = 1
  
      entries.each do |e|
        e.team_number = team_number
        e.multiple_teams = multi_flag
        e.save(validate: false)
  
        team_number += 1
      end
    end
  
    def self.import_excel(file, user)
      creates = 0
      updates = 0
      errors = 0
      error_list = []

      xlsx = Roo::Spreadsheet.open(file)

      xlsx.sheet(xlsx.default_sheet).parse(headers: true).each do |row|
        unless row['RowID'] == 'RowID'

          group = Group.find_by_abbr(row["Abbr"].to_s)
          if group
              group.database_rowid          = row['RowID'].to_i
              group.name                    = row['Name']
              group.short_name              = row['ShortName']
              group.coming                  = row['Coming']
              group.status                  = row['Status']
              group.new_group               = row['NewGroup']
              group.last_year               = row['LastYear']
              group.admin_use               = row['Admin']
              group.trading_name            = row['TradingName']  
              group.address                 = row['Address']
              group.suburb                  = row['Suburb']
              group.postcode                = row['Postcode'].to_i
              group.phone_number            = row['Phone']
              group.email                   = row['Email']
              group.website                 = row['Website']
              group.denomination            = row['Denomination']
              group.ticket_email            = row['TicketEmail']
              group.ticket_preference       = row['TicketPref']
              group.years_attended          = row['YearsAttended'].to_i
              group.updated_by = user.id

              if group.save
                  updates += 1
              else
                  errors += 1
                  error_list << group
              end
          else
              group = Group.create(
                 database_rowid:          row['RowID'],
                 abbr:                    row['Abbr'],
                 name:                    row['Name'],
                 short_name:              row['ShortName'],
                 coming:                  row['Coming'],
                 status:                  row['Status'],
                 new_group:               row['NewGroup'],
                 last_year:               row['LastYear'],
                 admin_use:               row['Admin'],
                 trading_name:            row['TradingName'],
                 address:                 row['Address'],
                 suburb:                  row['Suburb'],
                 postcode:                row['Postcode'].to_i,
                 phone_number:            row['Phone'],
                 email:                   row['Email'],
                 website:                 row['Website'],
                 denomination:            row['Denomination'],
                 ticket_email:            row['TicketEmail'],
                 ticket_preference:       row['TicketPref'],
                 years_attended:          row['YearsAttended'],
                 updated_by:              user.id)

              if group.errors.empty?
                  creates += 1
              else
                  errors += 1
                  error_list << group
              end
          end
        end
      end

      { creates: creates, updates: updates, errors: errors, error_list: error_list }
    end
  
    private
  
    def nz(amount)
      amount.nil? ? 0 : amount
    end
  
    def uppercase_abbr!
      self.abbr = self.abbr.strip
      self.abbr = self.abbr.upcase
    end
  
    def create_event_details!
      unless self.event_detail
        EventDetail.create(
          group_id:            self.id,
          buddy_interest:      "Not interested",
          updated_by:          self.updated_by
        )
      end
    end

    def create_mysyg_setting!
      unless self.mysyg_setting
        MysygSetting.create(
          group_id:            self.id,
          mysyg_name:          self.short_name.downcase.gsub(/[\[\] ,\.\/\']/,'')
        )
      end
    end

    def create_rego_checklist!
      unless self.rego_checklist
        RegoChecklist.create(
          group_id:            self.id
        )
      end
    end

    def check_mysyg_name
      if self.short_name_changed?
        if self.mysyg_setting
          ms = self.mysyg_setting
          ms.update_name!(self.short_name)
        end
      end
    end

    # TODO: Move this to either Participant or SportGrade
    def gender_matches_gender_type(gender, gender_type)
      if gender_type == 'Mens' && !gender.casecmp('f').zero? ||
         gender_type == 'Ladies' && !gender.casecmp('m').zero? ||
         gender_type == 'Mixed' ||
         gender_type == 'Open'
        true
      end
    end
  
    def grade_type_entries(sport, type)
      type_hash = { 'Singles' => 'Individual',
                    'Doubles' => 'Individual',
                    'Team' => 'Team' }
  
      entry_count = 0
      cached_sport_entries.collect do |entry|
        if type_hash[entry.grade_type] == type_hash[type] &&
           entry.sport.id == sport.id
          entry_count += 1
        end
      end
      entry_count
    end
  
    def grade_type_entries_in_grade(grade, type)
      entry_count = 0
      cached_sport_entries.collect do |entry|
        if entry.grade.id == grade.id
          entry_count += 1
        end
      end
      entry_count
    end
  
    def self.assign_short_name(name)
      sname = name.split[0]
      group = Group.find_by_short_name(sname)
      if group
        if name.split[1].nil?
          i = '0'.dup
          while group
            sname = name.split[0] + i.succ!
            group = Group.find_by_short_name(sname)
          end
        else
          sname = name.split[0] + ' ' + name.split[1]
        end
      end
      sname
    end
  
    def self.assign_abbr(name)
      # grab the first character of each word in the name (maximum of 4
      # and minimum of 2)
      abbr = name.split.collect { |word| word[0, 1] }.sum('').to_s.upcase
      abbr *= 2 until abbr.length > 1
      abbr = abbr[0, 4]
  
      # ensure uniqueness
      loop do
        group = Group.find_by_abbr(abbr)
        break unless group
        abbr = abbr.succ
      end
      abbr
    end

    def self.sync_fields
        ['name',
         'coming',
         'database_rowid',
         'short_name',
         'admin_use',
         'abbr',
         'new_group',
         'last_year'
        ]
    end
end
