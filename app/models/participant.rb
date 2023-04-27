# == Schema Information
#
# Table name: participants
#
#  id                     :bigint           not null, primary key
#  address                :string(200)
#  age                    :integer          default(30), not null
#  allergies              :string(255)
#  amount_paid            :decimal(8, 2)    default(0.0)
#  camping_preferences    :string(100)
#  coming                 :boolean          default(TRUE)
#  coming_friday          :boolean          default(TRUE)
#  coming_monday          :boolean          default(TRUE)
#  coming_saturday        :boolean          default(TRUE)
#  coming_sunday          :boolean          default(TRUE)
#  database_rowid         :integer
#  dietary_requirements   :string(255)
#  driver                 :boolean          default(FALSE)
#  driver_signature       :boolean          default(FALSE)
#  driver_signature_date  :datetime
#  driving_to_syg         :boolean          default(FALSE)
#  early_bird             :boolean          default(FALSE)
#  email                  :string(100)
#  emergency_contact      :string(40)
#  emergency_email        :string(100)
#  emergency_phone_number :string(20)
#  emergency_relationship :string(20)
#  fee_when_withdrawn     :decimal(8, 2)    default(0.0)
#  first_name             :string(20)       not null
#  gender                 :string(1)        default("M"), not null
#  group_coord            :boolean          default(FALSE)
#  guest                  :boolean          default(FALSE)
#  helper                 :boolean          default(FALSE)
#  late_fee_charged       :boolean          default(FALSE)
#  licence_type           :string(15)
#  lock_version           :integer          default(0)
#  medical_info           :string(255)
#  medicare_number        :string
#  medications            :string(255)
#  mobile_phone_number    :string(20)
#  number_plate           :string(10)
#  onsite                 :boolean          default(TRUE)
#  paid                   :boolean          default(FALSE)
#  phone_number           :string(20)
#  postcode               :integer
#  rego_type              :string(10)       default("Full Time")
#  spectator              :boolean          default(FALSE)
#  sport_coord            :boolean          default(FALSE)
#  sport_notes            :string
#  status                 :string(20)       default("Accepted")
#  suburb                 :string(40)
#  surname                :string(20)       not null
#  updated_by             :bigint
#  vaccinated             :boolean          default(FALSE)
#  vaccination_document   :string(40)
#  vaccination_sighted_by :string(20)
#  withdrawn              :boolean          default(FALSE)
#  wwcc_number            :string
#  years_attended         :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  group_id               :bigint           default(0), not null
#  voucher_id             :bigint
#
# Indexes
#
#  index_participants_on_coming                               (coming)
#  index_participants_on_group_id_and_surname_and_first_name  (group_id,surname,first_name) UNIQUE
#  index_participants_on_surname_and_first_name               (surname,first_name)
#  index_participants_on_voucher_id                           (voucher_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#

class Participant < ApplicationRecord
    include Auditable
    include Searchable

    require 'csv'
    require 'pp'

    attr_reader :voucher_name

    belongs_to :group
    belongs_to :voucher, optional: true
    has_many   :volunteers
    has_many   :participants_sport_entries #, dependent: :destroy
#    has_many   :fee_audit_trails
    has_many   :sport_entries, through: :participants_sport_entries
    has_many   :sport_preferences, dependent: :destroy
    has_many   :participant_extras, dependent: :destroy
    has_many   :captaincies, class_name: 'SportEntry'
    has_and_belongs_to_many :users

    scope :coming, -> { where(coming: true) }
    scope :not_coming, -> { where(coming: false) }
    scope :requiring_approval, -> { where(status: 'Requiring Approval') }
    scope :accepted, -> { where(status: 'Accepted') }
    scope :spectators, -> { where(spectator: true) }
    scope :playing_sport, -> { where(spectator: false) }
    scope :campers, -> { where(onsite: true) }
    scope :offsite, -> { where(onsite: false) }
    scope :group_coords, -> { where(group_coord: true) }
    scope :sport_coords, -> { where(sport_coord: true) }
    scope :helpers, -> { where(helper: true) }
    scope :open_age, -> { where('age > 17') }
    scope :volunteer_age, -> { where('age > 15') }
    scope :children, -> { where('age < 12') }
    scope :to_be_charged, -> { where("(coming = true OR withdrawn = true) AND status = 'Accepted'") }
    scope :drivers, -> { where(driver: true) }
    scope :males, -> { where("gender IN ('M', 'm', 'U', 'u')") }
    scope :females, -> { where("gender IN ('F', 'f', 'U', 'u')") }
    scope :day_visitors, -> { where(spectator: true).where(onsite: false) }

    delegate :group_extras, to: :group

    encrypts :wwcc_number, :medicare_number

    SEX = [['Male', 'M'],
           ['Female', 'F'],
           ['Prefer not to say', 'U']].freeze
  
    LICENCE_TYPES = ['Full',
                     'Green P-Plate',
                     'Red P-Plate'].freeze
  
    validates :first_name,             
        presence: true,
        uniqueness: { scope: %i[surname group_id],
        case_sensitive: false,
        message: 'creates a duplicate name' },
        length: { maximum: 20 }
    validates :surname,                
        presence: true,
        length: { maximum: 20 }
    validates :age,                    
        presence: true,
        numericality: { only_integer: true },
        inclusion: { in: 0..130, message: 'should be between 0 and 130' }
    validates :gender,                 
        presence: true,
        length: { maximum: 1 },
        inclusion: { in: %w[m f u M F U], message: "should be 'Male', 'Female' or 'Prefer not to say'" }
    validates :number_plate,           
        length: { maximum: 10 }
    validates :licence_type,           
        length: { maximum: 15 },
        inclusion: { in: LICENCE_TYPES }, 
        allow_blank: true
    validates :amount_paid,            
        numericality: true,
        allow_blank: true
    validates :fee_when_withdrawn,     
        numericality: true,
        allow_blank: true
    validates :address,                
        length: { maximum: 200 }
    validates :suburb,                 
        length: { maximum: 40 }
    validates :postcode,               
        numericality: { only_integer: true },
        allow_blank: true
    validates :phone_number,           
        length: { maximum: 20 }
    validates :mobile_phone_number,    
        length: { maximum: 20 }
    validates :email,                  
        presence: true,
        length: { maximum: 100 }
    validates :email,                  
        format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, message: 'invalid format' },
        allow_blank: true,
        unless: proc { |o| o.email.blank? }
    validates :medical_info,           
        length: { maximum: 255 }
    validates :medications,            
        length: { maximum: 255 }
    validates :allergies,            
        presence: true,
        length: { maximum: 255 }
    validates :years_attended,         
        numericality: { only_integer: true },
        allow_blank: true
    validates :dietary_requirements,   
        presence: true,
        length: { maximum: 255 }
    validates :emergency_contact,      
        length: { maximum: 40 }
    validates :emergency_relationship, 
        length: { maximum: 20 }
    validates :emergency_phone_number, 
        length: { maximum: 20 }
    validates :emergency_email,                  
        length: { maximum: 100 }
    validates :emergency_email,                  
        format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, message: 'invalid format' },
        allow_blank: true,
        unless: proc { |o| o.emergency_email.blank? }
    validates :camping_preferences, 
        length: { maximum: 100 }
    validates :camping_preferences, 
        length: { maximum: 255 }
    validates :vaccination_document, 
        length: { maximum: 40 }
    validates :vaccination_sighted_by, 
        length: { maximum: 20 }

    before_validation :validate_eligibility_for_team_helper
    before_validation :validate_eligibility_for_group_coordinator
    before_validation :validate_years_attended
    before_validation :validate_days_if_coming
    before_validation :validate_emergency_contact_details_if_under_18
    before_validation :normalize_first_name!
    before_validation :normalize_surname!
    before_validation :normalize_gender!

    before_create :set_early_bird_flag!
    before_update :check_early_bird_flag

    before_update :check_participant_sport_entries
    before_destroy :remove_sport_entries!
    after_destroy :release_volunteers!

    before_save :normalize_phone_numbers!
    before_save :normalize_medical_info!
    before_save :normalize_medications!
    before_save :normalize_address!
    before_save :normalize_suburb!
    before_save :set_rego_type!
    before_save :set_database_rowid!
    before_save :check_onsite_flag

    searchable_by :first_name, :surname, :email, :number_plate

    def self.finances
      h = {}
      Participant.coming.accepted.each do |participant|
        cat = participant.category
        a = h[cat] || Array.new(2, 0)
        a[0] += 1
        a[1] += participant.fee
        h[cat] = a
      end
      h.sort
    end
  
#    def self.total_fees
#      coming.accepted.to_a.sum(&:fee)
#    end
  
    def name
        first_name + ' ' + surname
    end
    
    def name_with_group_name
      if group.nil?
        name
      else
        name + ' (' + group.short_name + ')'
      end
    end

    def ticket_email
      if email.blank?
        gc_email
      else
        email
      end
    end

    def gc_email
      if self.group.users.primary.empty?
        self.group.gc_email
      else
        self.group.users.primary.first.email
      end
    end

    def days
      return 3 if self.rego_type == "Full Time"
      d = 0
      [:coming_friday, :coming_saturday, :coming_sunday, :coming_monday].each do |b|
        d += 1 if self.send(b) == true
      end
      [d, 3].min
    end

    def chargeable_days
      return 3 if self.rego_type == "Full Time"
      d = 0
      [:coming_saturday, :coming_sunday].each do |b|
        d += 1 if self.send(b) == true
      end
      d
    end

    def fee
      return fee_when_withdrawn if withdrawn
      settings = Setting.first
  
      base_fee = settings.full_fee
      # special 2019 hack due to spectator fee and early bird fee not 
      # being a multiple of 5
      base_fee -= 30 if spectator
      base_fee = 60 if spectator && days == 1
  
      # check for conditions requiring no charge
      return 0 unless coming
      return 0 if status == 'Requiring Approval'
      return 0 if age && (age < 6)
      return 0 if guest
      return 0 if !onsite && helper
  
      # other set-price conditions
      if !onsite && spectator
        if days == 1 && age && age >= 14
          fee = 30
        elsif age && age >= 14
          fee = 60
        end

        if fee && voucher
          fee = voucher.apply(fee)
        end

        return fee if fee
      end

      # subtract the early bird discount if appropriate
      base_fee -= settings.early_bird_discount if early_bird_applies?
  
      # check for other fee modifiers
      fee = base_fee
      fee *= settings.day_visitor_adjustment unless onsite
      fee = voucher.apply(fee) if voucher
      # special 2019 hack due to spectator fee and early bird fee not 
      # being a multiple of 5
      # fee *= settings.spectator_adjustment if spectator
      fee *= settings.primary_age_adjustment if age && (age < 14) && spectator
  
      gc_fee = group_coord ? fee * settings.coordinator_adjustment : fee
      sc_fee = sport_coord ? fee - sport_coord_discount : fee
      helper_fee = helper ? fee * settings.helper_adjustment : fee
  
      fee = [gc_fee, sc_fee, helper_fee].min
      fee = 0 if fee < 0
  
      # calculate the daily fee, and apply if staying for fewer than 2 chargeable days
      if spectator 
        daily_fee = base_fee
      else
        daily_fee = Participant.round_up_to_5(fee * settings.daily_adjustment)
      end
      total_fee = [Participant.round_up_to_5(fee), daily_fee * chargeable_days, base_fee].min
  
      total_fee
    end

    def early_bird_applies?
      !group_coord && !helper && early_bird && (chargeable_days >= 2) && voucher.nil?
    end

    def group_fee
      fee + extra_fee
    end
 
    def extra_fee
      if chargeable_days > 1
        group.extra_fee_total
      else
        [group.extra_fee_total, chargeable_days * group.extra_fee_per_day].min
      end
    end
  
    def total_owing
      group_fee + total_extras_costs
    end
  
    def paid_amount
      self.amount_paid.nil? ? 0 : self.amount_paid
    end

    def total_extras_costs
      participant_extras.wanted.to_a.sum(&:cost)
    end
  
    def sport_coord_discount
      sessions_coordinating = volunteers
                              .sport_coords
                              .where('participant_id is not null')
                              .count
  
      sessions_coordinating == 0 ? 0 : sessions_coordinating * 5 + 10
    end
      
    def category
      if guest && spectator
        'SYG Guest - Not playing sport'
      elsif guest && !spectator
        'SYG Guest - Playing sport'
      elsif sport_coord && spectator
        'SYG Sport Coordinator - Not playing sport'
      elsif sport_coord && !spectator
        'SYG Sport Coordinator - Playing sport'
      elsif group_coord && spectator
        'Group Coordinator - Not playing sport'
      elsif group_coord && !spectator
        'Group Coordinator - Playing sport'
      elsif helper && !onsite
        'Team Helper - Not staying onsite'
      elsif helper
        'Team Helper'
      elsif !onsite && spectator
        'Day Visitor'
      elsif !onsite && !spectator && early_bird && chargeable_days >= 2
        'Sport Participant (early bird)'
      elsif !onsite && !spectator
        'Sport Participant'
      elsif age && age < 6
        'Ages 0-5'
      elsif age && age < 14 && spectator
        'Child'
      elsif spectator && early_bird && chargeable_days >= 2
        'Spectator (early bird)'
      elsif spectator
        'Spectator'
      elsif early_bird && chargeable_days >= 2
        'Sport Participant (early bird)'
      else
        'Sport Participant'
      end
    end
  
    def voucher_code
      voucher.nil? ? '' : voucher.name
    end

    def accept!
      self.status = 'Accepted'
      save(validate: false)
    end
  
    def reject!
      self.group = Group.default_group
      self.coming = false
      save(validate: false)
    end
  
    # Mark this participant as having had a late fee charged,
    # so that we know not to charge it again
#    def charge_late_fee!
#      if coming && !late_fee_charged
#        self.late_fee_charged = true
#        save(validate: false)
#        group.charge_late_fee!
#      end
#    end

#    def withdraw!(old_fee)
#      self.withdrawn = true
#      self.coming = false
#      self.fee_when_withdrawn = old_fee
#      save(validate: false)
#    end

#    def reverse_withdrawal!
#      self.withdrawn = false
#      self.fee_when_withdrawn = 0
#      save(validate: false)
#    end

    def first_entry_in_grade(grade)
      sport_entries.select { |entry| entry.grade == grade }.first
    end

    def is_entered_in?(grade)
      sport_entries.collect(&:grade).include?(grade)
    end

#    def is_entered_in_session?(session)
#      sport_entries.collect(&:session).include?(session)
#    end

    def is_entered_in_sport?(sport)
      sport_entries.collect(&:sport).include?(sport)
    end

    def can_play_sport(sport)
      sport.indiv_entries(self) < sport.max_entries_indiv
    end

    def can_play_grade(grade)
      grade.sport.indiv_entries(self) < grade.sport.max_entries_indiv
    end
    
  def sports_in_session(session)
    sports = []

    sport_entries.each do |entry|
      sports << entry.sport.name if entry.session_name == session
    end

    volunteers.each do |volunteer|
      if volunteer.session && volunteer.session.name == session
        sports << volunteer.sport_name
      end
    end

    sports
  end

  def available_sport_entries
    entries = []
    (group.sport_entries - sport_entries).sort.each do |entry|
      next unless can_play_sport(entry.sport) &&
                  can_play_grade(entry.grade) &&
                  entry.can_take_participants? &&
                  entry.eligible_to_participate?(self)
      entries << entry
    end
    entries
  end

  def available_grades
    grades = []
    group.grades_available(false).each do |grade|
      next unless can_play_sport(grade.sport) &&
                  can_play_grade(grade) &&
                  grade.eligible_to_participate?(self)
      grades << grade
    end
    grades
  end

  def available_sections
    sections = []
    group.grades_available(false).each do |grade|
      next unless can_play_sport(grade.sport) &&
                  can_play_grade(grade) &&
                  grade.eligible_to_participate?(self)

      grade.sections.each do |section|
        next unless section.can_take_more_entries?

        sections << section
      end
    end
    sections
  end

  def available_volunteers
    av_vol = []
    Volunteer.unfilled.order("volunteers.description, volunteer_type_id").each do |volunteer|
      next if age < volunteer.min_age
      av_vol << volunteer
    end
    av_vol
  end

  def grades
    sport_entries.each.collect(&:grade)
  end

  def group_grades_i_can_join
    grades = []
    group.grades.each do |grade|
      next unless can_play_sport(grade.sport) &&
                  can_play_grade(grade) &&
                  grade.eligible_to_participate?(self)
      grades << grade
    end
    grades
  end

#  def sport_entry_ids
#    sport_entries.collect(&:id)
#  end

    def driver_sign
      self.driver_signature ? "[electronic]" : ""
    end
  
    def date_driver_signed
      self.driver_signature_date.nil? ? '' : driver_signature_date.in_time_zone.strftime('%d/%m/%Y')
    end
  
    def self.import(file, user)
      creates = 0
      updates = 0
      errors = 0
      error_list = []

      CSV.foreach(file.path, headers: true) do |fields|
          group = Group.find_by_abbr(fields[1].to_s)
          if group.nil?
            group = Group.find_by_abbr("DFLT")
          end

          participant = Participant.where(first_name: fields[2], surname: fields[3], group_id: group.id).first
          if fields[22].nil? || fields[22] == '0'
            years_attended = nil
          else
            years_attended = fields[22].to_i
          end
          
          if participant
              participant.database_rowid          = fields[0].to_i
              participant.coming                  = fields[4]
              participant.status                  = fields[5]
              participant.age                     = fields[6].to_i
              participant.gender                  = fields[7]
              participant.rego_type               = fields[8]
              participant.coming_friday           = fields[9]
              participant.coming_saturday         = fields[10]
              participant.coming_sunday           = fields[11]
              participant.coming_monday           = fields[12]
              participant.address                 = fields[13]
              participant.suburb                  = fields[14]
              participant.postcode                = fields[15].to_i
              participant.phone_number            = fields[16]
              participant.mobile_phone_number     = fields[17]
              participant.email                   = fields[18]
              participant.medicare_number         = fields[19]
              participant.medical_info            = fields[20]
              participant.medications             = fields[21]
              participant.years_attended          = years_attended
              participant.spectator               = fields[23]
              participant.onsite                  = fields[24]
              participant.helper                  = fields[25]
              participant.group_coord             = fields[26]
              participant.sport_coord             = fields[27]
              participant.guest                   = fields[28]
              participant.driver                  = fields[29]
              participant.number_plate            = fields[30]
              participant.early_bird              = fields[31]
              participant.dietary_requirements    = fields[32]
              participant.emergency_contact       = fields[33]
              participant.emergency_relationship  = fields[34]
              participant.emergency_phone_number  = fields[35]
              participant.wwcc_number             = fields[36]
              participant.allergies               = fields[38]
              participant.emergency_email         = fields[39]
              participant.camping_preferences     = fields[40]
              participant.sport_notes             = fields[41]
              participant.updated_by = user.id

              if participant.save
                  updates += 1
              else
                  errors += 1
                  error_list << participant
              end
          else
              participant = Participant.create(
                 database_rowid:          fields[0],
                 group_id:                group.id,
                 first_name:              fields[2],
                 surname:                 fields[3],
                 coming:                  fields[4],
                 status:                  fields[5],
                 age:                     fields[6].to_i,
                 gender:                  fields[7],
                 rego_type:               fields[8],
                 coming_friday:           fields[9],
                 coming_saturday:         fields[10],
                 coming_sunday:           fields[11],
                 coming_monday:           fields[12],
                 address:                 fields[13],
                 suburb:                  fields[14],
                 postcode:                fields[15].to_i,
                 phone_number:            fields[16],
                 mobile_phone_number:     fields[17],
                 email:                   fields[18],
                 medicare_number:         fields[19],
                 medical_info:            fields[20],
                 medications:             fields[21],
                 years_attended:          years_attended,
                 spectator:               fields[23],
                 onsite:                  fields[24],
                 helper:                  fields[25],
                 group_coord:             fields[26],
                 sport_coord:             fields[27],
                 guest:                   fields[28],
                 driver:                  fields[29],
                 number_plate:            fields[30],
                 early_bird:              fields[31],
                 dietary_requirements:    fields[32],
                 emergency_contact:       fields[33],
                 emergency_relationship:  fields[34],
                 emergency_phone_number:  fields[35],
                 wwcc_number:             fields[36],
                 allergies:               fields[38],
                 emergency_email:         fields[39],
                 camping_preferences:     fields[40],
                 sport_notes:             fields[41],
                 updated_by:              user.id)

              if participant.errors.empty?
                  creates += 1
              else
                  errors += 1
                  error_list << participant
              end
          end
      end

      { creates: creates, updates: updates, errors: errors, error_list: error_list }
  end
  
  def self.import_gc(file, group, user)
    creates = 0
    updates = 0
    errors = 0
    error_list = []

    CSV.foreach(file.path, headers: true) do |fields|
        participant = Participant.where(first_name: fields[0], surname: fields[1], group_id: group.id).first
        if fields[20].nil? || fields[20] == '0'
          years_attended = nil
        else
          years_attended = fields[20].to_i
        end
      
        if participant
            participant.coming                  = fields[2]
            participant.age                     = fields[3].to_i
            participant.gender                  = fields[4]
            participant.rego_type               = fields[5]
            participant.coming_friday           = fields[6]
            participant.coming_saturday         = fields[7]
            participant.coming_sunday           = fields[8]
            participant.coming_monday           = fields[9]
            participant.address                 = fields[10]
            participant.suburb                  = fields[11]
            participant.postcode                = fields[12].to_i
            participant.phone_number            = fields[13]
            participant.mobile_phone_number     = fields[14]
            participant.email                   = fields[15]
            participant.medicare_number         = fields[16]
            participant.medical_info            = fields[17]
            participant.medications             = fields[18]
            participant.allergies               = fields[19]
            participant.years_attended          = years_attended
            participant.spectator               = fields[21]
            participant.onsite                  = fields[22]
            participant.helper                  = fields[23]
            participant.group_coord             = fields[24]
            participant.driver                  = fields[25]
            participant.number_plate            = fields[26]
            participant.dietary_requirements    = fields[27]
            participant.emergency_contact       = fields[28]
            participant.emergency_relationship  = fields[29]
            participant.emergency_phone_number  = fields[30]
            participant.wwcc_number             = fields[31]
            participant.updated_by = user.id

            if participant.save
                updates += 1
            else
                errors += 1
                error_list << participant
            end
        else
            participant = Participant.create(
               group_id:                group.id,
               first_name:              fields[0],
               surname:                 fields[1],
               coming:                  fields[2],
               age:                     fields[3].to_i,
               gender:                  fields[4],
               rego_type:               fields[5],
               coming_friday:           fields[6],
               coming_saturday:         fields[7],
               coming_sunday:           fields[8],
               coming_monday:           fields[9],
               address:                 fields[10],
               suburb:                  fields[11],
               postcode:                fields[12].to_i,
               phone_number:            fields[13],
               mobile_phone_number:     fields[14],
               email:                   fields[15],
               medicare_number:         fields[16],
               medical_info:            fields[17],
               medications:             fields[18],
               allergies:               fields[19],
               years_attended:          years_attended,
               spectator:               fields[21],
               onsite:                  fields[22],
               helper:                  fields[23],
               group_coord:             fields[24],
               driver:                  fields[25],
               number_plate:            fields[26],
               dietary_requirements:    fields[27],
               emergency_contact:       fields[28],
               emergency_relationship:  fields[29],
               emergency_phone_number:  fields[30],
               wwcc_number:             fields[31],
               updated_by:              user.id)

            if participant.errors.empty?
                creates += 1
            else
                errors += 1
                error_list << participant
            end
        end
    end

    { creates: creates, updates: updates, errors: errors, error_list: error_list }
  end

  def self.round_up_to_5(num)
    (num.to_f / 5).ceil * 5
  end

private
  def validate_days_if_coming
    if coming
      d = 0
      [:coming_friday, :coming_saturday, :coming_sunday, :coming_monday].each do |b|
        d += 1 if self.send(b) == true
      end
      errors.add(:coming, "at least one day must be selected if coming") if d == 0
    end
  end

  def validate_emergency_contact_details_if_under_18
    if age && age.to_i < 18
      errors.add(:emergency_contact, "can't be blank for under 18's") if emergency_contact.blank?
      errors.add(:emergency_relationship, "can't be blank for under 18's") if emergency_relationship.blank?
      errors.add(:emergency_phone_number, "can't be blank for under 18's") if emergency_phone_number.blank?
      errors.add(:emergency_email, "can't be blank for under 18's") if emergency_email.blank?
    end
  end

  def validate_eligibility_for_team_helper
    errors.add(:helper, 'must also be a spectator') if coming && helper && !spectator
    errors.add(:helper, 'must not be under 12') if coming && helper && age && age < 12
    errors.add(:helper, 'maximum number of Team Helpers has been reached') if coming && helper && group.participants.coming.accepted.helpers.where(['id != ?', id]).size >= group.helpers_allowed
  end

  def validate_eligibility_for_group_coordinator
    errors.add(:group_coord, 'Maximum of two Group Coordinators allowed per group') if coming && group_coord && group.participants.coming.accepted.group_coords.where(['id != ?', id]).size >= group.coordinators_allowed
  end

  def validate_years_attended
    setting = Setting.first
    unless years_attended.nil?
      max_year = setting.this_year - APP_CONFIG[:first_year] + 1
      errors.add('years_attended', "should be between 1 and #{max_year}") unless years_attended >= 1 && years_attended <= max_year
    end
  end

  def set_database_rowid!
    self.database_rowid ||= unique_auto_number
    nil
  end

  def set_rego_type!
    d = 0
    [:coming_friday, :coming_saturday, :coming_sunday, :coming_monday].each do |b|
      d += 1 if self.send(b) == true
    end
    self.rego_type = d == 4 ? "Full Time" : "Part Time"
  end

  def set_early_bird_flag!
    settings = Setting.first
    self.early_bird = settings.early_bird
  end

  def check_early_bird_flag
    if coming_changed? && coming
      set_early_bird_flag!
    end
  end

  def check_onsite_flag
    if !group.onsite && onsite
      self.onsite = false
    end
  end

  def check_participant_sport_entries
    case
    when coming_changed? && !coming
      remove_participant_from_entries!(self)
    when spectator_changed? && spectator
      remove_participant_from_entries!(self)
    end
  end

  def remove_sport_entries!
    remove_participant_from_entries!(self)
  end

  def remove_participant_from_entries!(participant)
    participant.sport_entries.each do |entry|
      sport_entry = SportEntry.find(entry.id)
      sport_entry.participants.destroy(participant)
      if sport_entry.captaincy == participant
        sport_entry.captaincy = nil
      end
      sport_entry.save
    end
  end

  def release_volunteers!
    volunteers.each do |o|
      o.participant_id = nil
      o.mobile_number = nil
      o.email = nil
      o.t_shirt_size = nil
      o.save(validate: false)
    end
  end

  def normalize_first_name!
    self.first_name = first_name.strip.titleize if first_name
  end

  def normalize_surname!
    self.surname = Participant.normalize_surname(surname) if surname
  end

  def normalize_gender!
    self.gender = gender.upcase if gender
  end

  def normalize_phone_numbers!
    self.phone_number = Participant.normalize_phone_number(phone_number) if phone_number
    self.mobile_phone_number = Participant.normalize_phone_number(mobile_phone_number) if mobile_phone_number
  end

  def normalize_medical_info!
    self.medical_info = Participant.normalize_medical_info(medical_info) if medical_info
  end

  def normalize_medications!
    self.medications = Participant.normalize_medical_info(medications) if medications
  end

  def normalize_address!
    self.address = Participant.normalize_address(address) if address
  end

  def normalize_suburb!
    self.suburb = Participant.normalize_suburb(suburb) if suburb
  end

  def self.normalize_phone_number(number)
    numbers = number.gsub(/\D/, '')
    if numbers.size == 10
      if numbers[0..1] == '04'
        "(#{numbers[0..3]}) #{numbers[4..6]}-#{numbers[7..9]}"
      else
        "(#{numbers[0..1]}) #{numbers[2..5]}-#{numbers[6..9]}"
      end
    elsif numbers.size == 8
      "(0#{APP_CONFIG[:state_area_code]}) #{numbers[0..3]}-#{numbers[4..7]}"
    else
      number
    end
  end

  def self.normalize_medical_info(info)
    if ['none', 'n/a', 'nil', '-', ''].include?(info.downcase)
      nil
    else
      info
    end
  end

  def self.normalize_suburb(suburb)
    words = suburb.split.collect do |word|
      if ['nth', 'nth.', 'n', 'n.'].include?(word.downcase)
        'North'
      elsif ['sth', 'sth.', 's', 's.'].include?(word.downcase)
        'South'
      elsif ['e', 'e.'].include?(word.downcase)
        'East'
      elsif ['w', 'w.'].include?(word.downcase)
        'West'
      else
        word.capitalize
      end
    end
    words.join(' ')
  end

  def self.normalize_surname(surname)
    words = surname.strip.split.collect do |word|
      parts = word.split("'").collect do |part|
        subparts = part.split('-').collect do |subpart|
          subpart[0..1].casecmp('mc').zero? ? "Mc#{subpart[2..99].capitalize}" : subpart.capitalize
        end
        subparts.join('-')
      end
      parts.join("'")
    end
    words.join(' ')
  end

  def self.normalize_address(address)
    words = address.split.collect do |word|
      parts = word.split("'").collect do |part|
        subparts = part.split('-').collect do |subpart|
          bits = subpart.split('/').collect do |bit|
            if ['po', 'p.o', 'p.o.'].include?(bit.downcase)
              'P.O.'
            elsif ['rmb', 'r.m.b', 'r.m.b.'].include?(bit.downcase)
              'R.M.B.'
            elsif ['rsd', 'r.s.d', 'r.s.d.'].include?(bit.downcase)
              'R.S.D.'
            elsif ['street', 'st.'].include?(bit.downcase)
              'St'
            elsif ['road', 'rd.'].include?(bit.downcase)
              'Rd'
            elsif %w[avenue av].include?(bit.downcase)
              'Ave'
            elsif ['close', 'cl.'].include?(bit.downcase)
              'Cl'
            elsif ['boulevard', 'blvd.'].include?(bit.downcase)
              'Blvd'
            elsif ['lane', 'ln.'].include?(bit.downcase)
              'Ln'
            elsif ['court', 'crt.'].include?(bit.downcase)
              'Crt'
            elsif ['grove', 'gr', 'gr.', 'gv', 'gv.'].include?(bit.downcase)
              'Gve'
            elsif ['crescent', 'cresent', 'cres.', 'crs', 'crs.'].include?(bit.downcase)
              'Cres'
            elsif ['place', 'pl.', 'plc', 'plc.'].include?(bit.downcase)
              'Pl'
            elsif ['parade', 'pde.'].include?(bit.downcase)
              'Pde'
            elsif ['drive', 'dr', 'drv', 'dr.', 'dve.'].include?(bit.downcase)
              'Dve'
            elsif ['terrace', 'tce.'].include?(bit.downcase)
              'Tce'
            elsif ['highway', 'hwy.'].include?(bit.downcase)
              'Hwy'
            elsif ['square', 'sq.'].include?(bit.downcase)
              'Sq'
            elsif ['track', 'tk.'].include?(bit.downcase)
              'Tk'
            else
              bit.capitalize
            end
          end
          bits.join('/')
        end
        subparts.join('-')
      end
      parts.join("'")
    end
    words.join(' ')
  end

  def auto_number
    rand(-2_147_483_648..2_147_483_647)
  end

  def unique_auto_number
    num = 0
    loop do
      num = auto_number
      participant = Participant.find_by_database_rowid(num)
      break if participant.nil?
    end
    num
  end

  def self.sync_fields
    ['first_name',
      'surname', 
      'group_id',
      'coming',
      'database_rowid',
      'age',
      'gender',
      'onsite',
      'address',
      'suburb',
      'postcode',
      'phone_number',
      'mobile_phone_number',
      'spectator',
      'helper',
      'group_coord',
      'sport_coord',
      'guest'
    ]
  end
end
