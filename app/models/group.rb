# == Schema Information
#
# Table name: groups
#
#  id               :bigint           not null, primary key
#  abbr             :string(4)        not null
#  address          :string(200)      not null
#  admin_use        :boolean
#  age_demographic  :string(40)
#  allocation_bonus :integer          default(0)
#  coming           :boolean          default(TRUE)
#  database_rowid   :integer
#  denomination     :string(40)       not null
#  email            :string(100)
#  group_focus      :string(100)
#  last_year        :boolean
#  late_fees        :decimal(8, 2)    default(0.0)
#  lock_version     :integer          default(0)
#  name             :string(100)      not null
#  new_group        :boolean          default(TRUE)
#  phone_number     :string(20)
#  postcode         :integer          not null
#  short_name       :string(50)       not null
#  status           :string(12)       default("Stale")
#  suburb           :string(40)       not null
#  trading_name     :string(100)      not null
#  updated_by       :bigint
#  website          :string(100)
#  years_attended   :integer          default(0)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
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

    require 'csv'

    has_many :participants
#    has_many :payments
#    has_many :sport_entries
#    has_many :downloads
#    has_many :group_extras
#    has_many :groups_sport_grades_filters
#    has_many :fee_audit_trails
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

    delegate :estimated_numbers, to: :event_detail

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
    validates :status,              length: { maximum: 12 },
                                    inclusion: { in: STATUS }
    validates :allocation_bonus,    numericality: { only_integer: true },
                                    allow_blank: true
    validates :late_fees,           numericality: true,
                                    allow_blank: true

    searchable_by :abbr, :name, :short_name, :trading_name

    before_save :uppercase_abbr!
    after_save :create_event_details!
    after_save :create_mysyg_setting!
    after_save :create_rego_checklist!

    def <=>(other)
        name <=> other.name
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
    
    def coordinators_allowed
        2
    end
    
    def church_rep
      @church_rep ||= users.church_reps.not_stale.first
    end

    def church_rep_name
      church_rep.nil? ? '' : church_rep.fullname
    end

    def church_rep_phone_number
      church_rep.nil? ? '' : church_rep.phone_number
    end

    def church_rep_wwcc
      church_rep.nil? ? '' : church_rep.wwcc_number
    end

    def gc
      @gc ||= users.gcs.not_stale.primary.first
    end

    def gc_name
      gc.nil? ? '' : gc.fullname
    end

    def gc_phone_number
      gc.nil? ? '' : gc.phone_number
    end

    def gc_wwcc
      gc.nil? ? '' : gc.wwcc_number
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
  
    def reset_allocation_bonus!
        self.allocation_bonus = 0
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

    def participants_allowed_per_session 
      [estimated_numbers, participants.size].max * 1.5    
    end
  
    def number_playing_sport
      @number_playing_sport ||= participants.playing_sport.coming.accepted.size
    end
  
    def helpers_allowed
      4 + (participants.coming.accepted.playing_sport.size >= 40 ?
         (participants.coming.accepted.playing_sport.size / 20).to_i : 0)
    end
  
    def helpers
      participants.coming.accepted.helpers
    end
  
    def free_helpers
      if division == 'Small Churches'
        2
      elsif division == 'Medium Churches'
        4
      else
        6
      end
    end
  
    def helper_rebate
      helper_fees = helpers.collect(&:fee)
  
      helper_fees.sort.last(free_helpers).sum
    end
  
    def increment_allocation_bonus!
        settings = Setting.first
        self.allocation_bonus += settings.missed_out_sports_allocation_factor
        save(validate: false)
    end

    def self.import(file, user)
        creates = 0
        updates = 0
        errors = 0
        error_list = []
  
        CSV.foreach(file.path, headers: true) do |fields|
            group = Group.find_by_abbr(fields[1].to_s)
            if group
                group.database_rowid          = fields[0].to_i
                group.name                    = fields[2]
                group.short_name              = fields[3]
                group.coming                  = fields[4]
                group.status                  = fields[5]
                group.new_group               = fields[6]
                group.last_year               = fields[7]
                group.admin_use               = fields[8]
                group.trading_name            = fields[9]  
                group.address                 = fields[10]
                group.suburb                  = fields[11]
                group.postcode                = fields[12].to_i
                group.phone_number            = fields[13]
                group.email                   = fields[14]
                group.website                 = fields[15]
                group.denomination            = fields[16]
                group.updated_by = user.id
 
                if group.save
                    updates += 1
                else
                    errors += 1
                    error_list << group
                end
            else
                group = Group.create(
                   database_rowid:          fields[0],
                   abbr:                    fields[1],
                   name:                    fields[2],
                   short_name:              fields[3],
                   coming:                  fields[4],
                   status:                  fields[5],
                   new_group:               fields[6],
                   last_year:               fields[7],
                   admin_use:               fields[8],
                   trading_name:            fields[9],
                   address:                 fields[10],
                   suburb:                  fields[11],
                   postcode:                fields[12].to_i,
                   phone_number:            fields[13],
                   email:                   fields[14],
                   website:                 fields[15],
                   denomination:            fields[16],
                   updated_by:              user.id)

                if group.errors.empty?
                    creates += 1
                else
                    errors += 1
                    error_list << group
                end
            end
        end
  
        { creates: creates, updates: updates, errors: errors, error_list: error_list }
    end
    
    private
  
    def uppercase_abbr!
      abbr.upcase!
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
          mysyg_name:          self.short_name.downcase
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
      abbr = name.split.collect { |word| word[0, 1] }.sum.to_s.upcase
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
