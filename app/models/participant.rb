# == Schema Information
#
# Table name: participants
#
#  id                           :bigint           not null, primary key
#  address                      :string(200)
#  age                          :integer          default(30), not null
#  amount_paid                  :decimal(8, 2)    default(0.0)
#  coming                       :boolean          default(TRUE)
#  database_rowid               :integer
#  days                         :integer          default(3), not null
#  dietary_requirements         :string(255)
#  driver                       :boolean          default(FALSE)
#  driver_signature             :boolean          default(FALSE)
#  driver_signature_date        :datetime
#  early_bird                   :boolean          default(FALSE)
#  email                        :string(100)
#  emergency_contact            :string(40)
#  emergency_phone_number       :string(20)
#  emergency_relationship       :string(20)
#  encrypted_medicare_number    :string
#  encrypted_medicare_number_iv :string
#  encrypted_wwcc_number        :string
#  encrypted_wwcc_number_iv     :string
#  fee_when_withdrawn           :decimal(8, 2)    default(0.0)
#  first_name                   :string(20)       not null
#  gender                       :string(1)        default("M"), not null
#  group_coord                  :boolean          default(FALSE)
#  guest                        :boolean          default(FALSE)
#  helper                       :boolean          default(FALSE)
#  late_fee_charged             :boolean          default(FALSE)
#  lock_version                 :integer          default(0)
#  medical_info                 :string(255)
#  medications                  :string(255)
#  mobile_phone_number          :string(20)
#  number_plate                 :string(10)
#  onsite                       :boolean          default(TRUE)
#  phone_number                 :string(20)
#  postcode                     :integer
#  spectator                    :boolean          default(FALSE)
#  sport_coord                  :boolean          default(FALSE)
#  status                       :string(20)       default("Accepted")
#  suburb                       :string(40)
#  surname                      :string(20)       not null
#  updated_by                   :bigint
#  withdrawn                    :boolean          default(FALSE)
#  years_attended               :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  group_id                     :bigint           default(0), not null
#
# Indexes
#
#  index_participants_on_coming                               (coming)
#  index_participants_on_group_id_and_surname_and_first_name  (group_id,surname,first_name) UNIQUE
#  index_participants_on_surname_and_first_name               (surname,first_name)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#
class Participant < ApplicationRecord
    include Auditable
    include Searchable

    require 'csv'

    belongs_to :group
#    has_many   :officials
#    has_many   :helpers
#    has_many   :securities
#    has_many   :participants_sport_entries
#    has_many   :fee_audit_trails
#    has_many   :sport_entries, through: :participants_sport_entries
#    has_many   :sport_preferences, dependent: :destroy
#    has_many   :participant_extras, dependent: :destroy
#    has_many   :captaincies, class_name: 'SportEntry'

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
    scope :children, -> { where('age < 12') }
    scope :to_be_charged, -> { where("(coming = true OR withdrawn = true) AND status = 'Accepted'") }
    scope :drivers, -> { where(driver: true) }
    scope :males, -> { where("gender IN ('M', 'm')") }
    scope :females, -> { where("gender IN ('F', 'f')") }
    scope :day_visitors, -> { where(spectator: true).where(onsite: false) }

    attr_encrypted :wwcc_number, key: 'b8fb31b1c77b81b307615296b7f5ccec'
    attr_encrypted :medicare_number, key: 'b8fb31b1c77b81b307615296b7f5ccec'

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
        inclusion: { in: %w[m f M F], message: "should be 'm' or 'f'" }
    validates :days,                   
        presence: true,
        numericality: { only_integer: true },
        inclusion: { in: 1..3, message: 'should be between 1 and 3' }
    validates :number_plate,           
        length: { maximum: 10 }
    validates :amount_paid,            
        numericality: true
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
        length: { maximum: 100 }
    validates :email,                  
        format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, message: 'invalid format' },
        allow_blank: true,
        unless: proc { |o| o.email.blank? }
    validates :medical_info,           
        length: { maximum: 255 }
    validates :medications,            
        length: { maximum: 255 }
    validates :years_attended,         
        numericality: { only_integer: true },
        allow_blank: true
    validates :dietary_requirements,   
        length: { maximum: 255 }
    validates :emergency_contact,      
        length: { maximum: 40 }
    validates :emergency_relationship, 
        length: { maximum: 20 }
    validates :emergency_phone_number, 
        length: { maximum: 20 }

#    before_validation :validate_eligibility_for_team_helper
#    before_validation :validate_eligibility_for_group_coordinator
#    before_validation :validate_years_attended
#    before_validation :validate_participant_limits_on_create, on: :create
#    before_validation :validate_participant_limits_on_update, on: :update

    before_validation :normalize_first_name!
    before_validation :normalize_surname!
    before_validation :normalize_gender!

#    before_save :set_database_rowid!
    before_save :normalize_phone_numbers!
    before_save :normalize_medical_info!
    before_save :normalize_medications!
    before_save :normalize_address!
    before_save :normalize_suburb!

    searchable_by :first_name, :surname, :email, :number_plate

    SEX = %w[M F].freeze
    DAYS = [3, 2, 1].freeze
  
    def name
        first_name + ' ' + surname
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
          
          if participant
              participant.database_rowid          = fields[0].to_i
              participant.coming                  = fields[4]
              participant.status                  = fields[5]
              participant.age                     = fields[6].to_i
              participant.gender                  = fields[7]
              participant.days                    = fields[8].to_i
              participant.address                 = fields[9]
              participant.suburb                  = fields[10]
              participant.postcode                = fields[11].to_i
              participant.phone_number            = fields[12]
              participant.mobile_phone_number     = fields[13]
              participant.email                   = fields[14]
              participant.medicare_number         = fields[15]
              participant.medical_info            = fields[16]
              participant.medications             = fields[17]
              participant.years_attended          = fields[18].to_i
              participant.spectator               = fields[19]
              participant.onsite                  = fields[20]
              participant.helper                  = fields[21]
              participant.group_coord             = fields[22]
              participant.sport_coord             = fields[23]
              participant.guest                   = fields[24]
              participant.driver                  = fields[25]
              participant.number_plate            = fields[26]
              participant.early_bird              = fields[27]
              participant.dietary_requirements    = fields[28]
              participant.emergency_contact       = fields[29]
              participant.emergency_relationship  = fields[30]
              participant.emergency_phone_number  = fields[31]
              participant.wwcc_number             = fields[32]
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
                 days:                    fields[8].to_i,
                 address:                 fields[9],
                 suburb:                  fields[10],
                 postcode:                fields[11].to_i,
                 phone_number:            fields[12],
                 mobile_phone_number:     fields[13],
                 email:                   fields[14],
                 medicare_number:         fields[15],
                 medical_info:            fields[16],
                 medications:             fields[17],
                 years_attended:          fields[18].to_i,
                 spectator:               fields[19],
                 onsite:                  fields[20],
                 helper:                  fields[21],
                 group_coord:             fields[22],
                 sport_coord:             fields[23],
                 guest:                   fields[24],
                 driver:                  fields[25],
                 number_plate:            fields[26],
                 early_bird:              fields[27],
                 dietary_requirements:    fields[28],
                 emergency_contact:       fields[29],
                 emergency_relationship:  fields[30],
                 emergency_phone_number:  fields[31],
                 wwcc_number:             fields[32],
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
  
private

    def validate_eligibility_for_team_helper
      errors[:base] << 'Team helpers must also be spectators' if coming && helper && !spectator
      errors[:base] << 'Team helpers must not be under 12' if coming && helper && age && age < 12
      errors[:base] << 'Maximum number of Team Helpers has been reached' if coming && helper && group.participants.coming.accepted.helpers.where(['id != ?', id]).size >= group.helpers_allowed
    end
  
    def validate_eligibility_for_group_coordinator
      errors[:base] << 'Maximum of two Group Coordinators allowed per group' if coming && group_coord && group.participants.coming.accepted.group_coords.where(['id != ?', id]).size >= group.coordinators_allowed
    end
  
    def validate_years_attended
      unless years_attended.nil?
        max_year = APP_CONFIG[:this_year] - APP_CONFIG[:first_year] + 1
        errors.add('years_attended', "should be between 1 and #{max_year}") unless years_attended >= 1 && years_attended <= max_year
      end
    end
  
    def normalize_first_name!
      self.first_name = first_name.titleize if first_name
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
      words = surname.split.collect do |word|
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

    def self.sync_fields
      ['first_name',
       'surname', 
       'group_id',
       'coming',
       'database_rowid',
       'age',
       'gender',
       'days',
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
