# frozen_string_literal: true

class ParticipantSignup
    extend ActiveModel::Callbacks
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    include ActiveModel::Conversion
    extend ActiveModel::Naming
  
    attr_accessor :password,
                  :first_name,
                  :surname,
                  :group_id,
                  :coming,
                  :voucher_name,
                  :status,
                  :spectator,
                  :onsite,
                  :age,
                  :gender,
                  :coming_friday,
                  :coming_saturday,
                  :coming_sunday,
                  :coming_monday,
                  :group_coord,
                  :helper,
                  :address,
                  :suburb,
                  :postcode,
                  :phone_number,
                  :mobile_phone_number,
                  :email,
                  :years_attended,
                  :wwcc_number,
                  :medicare_number,
                  :medical_info,
                  :medications,
                  :dietary_requirements,
                  :emergency_contact,
                  :emergency_relationship,
                  :emergency_phone_number,
                  :driver,
                  :number_plate,
                  :driver_signature,
                  :participant,
                  :user,
                  :group
  
    INTEGER_FIELDS = %w[age].freeze
  
    PARTICIPANT_ATTRIBUTES = [
      :first_name,
      :surname,
      :group_id,
      :coming,
      :voucher_name,
      :status,
      :age,
      :onsite,
      :gender,
      :coming_friday,
      :coming_saturday,
      :coming_sunday,
      :coming_monday,
      :spectator,
      :group_coord,
      :helper,
      :address,
      :suburb,
      :postcode,
      :phone_number,
      :mobile_phone_number,
      :email,
      :years_attended,
      :wwcc_number,
      :medicare_number,
      :medical_info,
      :medications,
      :dietary_requirements,
      :emergency_contact,
      :emergency_relationship,
      :emergency_phone_number,
      :driver,
      :number_plate,
      :driver_signature
    ].compact
  
    USER_ATTRIBUTES = %i[
      address
      suburb
      postcode
      phone_number
      email
    ].freeze
  
    STATUSES = ['Requiring Approval',
                'Accepted'].freeze
  
    validates :password,               confirmation: true,
                                       length: { within: 5..40 },
                                       allow_nil: true
    validates :email,                  presence: true,
                                       length: { maximum: 100 },
                                       format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
                                                 message: 'invalid format' }
    validates :group_id,               presence: true
    validates :first_name,             presence: true,
                                       length: { maximum: 20 }
    validates :surname,                presence: true,
                                       length: { maximum: 20 }
    validates :status,                 presence: true,
                                       inclusion: { in: STATUSES, message: 'status is invalid value' }
    validates :age,                    presence: true,
                                       numericality: { only_integer: true },
                                       inclusion: { in: 0..130, message: 'should be between 0 and 130' }
    validates :gender,                 presence: true,
                                       length: { maximum: 1 },
                                       inclusion: { in: %w[m f M F], message: "should be 'm' or 'f'" }
    validates :days,                   presence: true,
                                       numericality: { only_integer: true },
                                       inclusion: { in: 1..3, message: 'should be between 1 and 3' }
    validates :number_plate,           length: { maximum: 10 }
    validates :address,                presence: true,
                                       length: { maximum: 200 }
    validates :suburb,                 presence: true,
                                       length: { maximum: 40 }
    validates :postcode,               presence: true,
                                       numericality: { only_integer: true }
    validates :phone_number,           presence: true,
                                       length: { maximum: 20 }
    validates :mobile_phone_number,    length: { maximum: 20 }
    validates :wwcc_number,            length: { maximum: 20 }
    validates :medicare_number,        length: { maximum: 50 }
    validates :medical_info,           length: { maximum: 255 }
    validates :medications,            length: { maximum: 255 }
    validates :years_attended,         numericality: { only_integer: true },
                                       allow_blank: true
    validates :dietary_requirements,   length: { maximum: 255 }
    validates :emergency_contact,      length: { maximum: 40 }
    validates :emergency_relationship, length: { maximum: 20 }
    validates :emergency_phone_number, length: { maximum: 20 }
  
    before_validation :validate_emergency_contact_details_if_under_18
#    before_validation :validate_consent_provided
    before_validation :validate_years_attended
  
    before_validation :normalize_first_name!
    before_validation :normalize_surname!
    before_validation :normalize_gender!
  
    def initialize(attributes = {})
      send_attributes(attributes)
      @participant = find_or_create_participant
      @user = find_or_create_user
      @group = find_group
    end
  
    def update_attributes(attributes = {})
      send_attributes(attributes)
      save
    end
  
    def self.find(id)
      pu = ParticipantSignup.new
  
      pu.participant = Participant.where(id: id).first || Participant.new
      pu.group = pu.participant.group
  
      pu.load_participant
      pu.user = User.unscoped.find_by_participant_id(pu.participant.id) || User.new
      pu.load_user
  
      pu
    end
  
    def self.locate(user)
      pu = ParticipantSignup.new
  
      pu.user = user
      pu.participant = Participant.where(id: user.participant_id).first || Participant.new
      pu.group = pu.participant.group
  
      pu.load_participant
      pu.load_user
      pu
    end
  
    def save
      if valid?
        update_participant
  
        if @participant.valid?
          @participant.save
        else
          @participant.errors.each do |key, value|
            errors.add key, value
          end
          return false
        end
  
        update_user
  
        if @user.valid?
          @user.save
        else
          @user.errors.each do |key, value|
            errors.add key, value
          end
          false
        end
      else
        false
      end
    end
  
    def save!
      update_participant
      @participant.save!
  
      update_user
      @user.save!
    end
  
#    def record_consent(params)
#      @params = params
  
#      if @participant.consent
#        @participant.consent.update_attributes(consent_params)
#        if @participant.consent.valid?
#          @participant.consent.save
#        else
#          return false
#        end
#      else
#        @participant.consent = Consent.new(consent_params)
#        if @participant.consent.valid?
#          @participant.save
#          @participant.consent.save
#        else
#          return false
#        end
#      end
#    end
  
    def load_participant
      PARTICIPANT_ATTRIBUTES.each do |name|
        send("#{name}=", @participant.send(name))
      end
    end
  
    def load_user
      USER_ATTRIBUTES.each do |name|
        send("#{name}=", @user.send(name))
      end
    end
  
    def persisted?
      false
    end
  
    def send_attributes(attributes = {})
      attributes.each do |name, value|
        if INTEGER_FIELDS.include?(name)
          value = value.to_i
        else
          value = value.strip if value.respond_to?(:strip)
        end
  
        send("#{name}=", value)
      end
    end
  
 #   def validate_consent_provided
 #     unless agreement.nil?
 #       errors.add(:age_confirmation, 'must be provided') unless age_confirmation
 #       errors.add(:responsibility_confirmation, 'must be provided') unless responsibility_confirmation
 #       errors.add(:medical_permission, 'must be provided') unless medical_permission
 #       errors.add(:insurance_confirmation, 'must be provided') unless insurance_confirmation
 #       errors.add(:agreement, 'must be provided') unless agreement
 #     end
 #   end
  
    private
  
#    def consent_params
#      @params.permit(:age_confirmation,
#                     :responsibility_confirmation,
#                     :medical_permission,
#                     :insurance_confirmation,
#                     :agreement)
#    end
  
    def validate_emergency_contact_details_if_under_18
      if age && age.to_i < 18
        errors.add(:emergency_contact, "can't be blank for under 18's") if emergency_contact.blank?
        errors.add(:emergency_relationship, "can't be blank for under 18's") if emergency_relationship.blank?
        errors.add(:emergency_phone_number, "can't be blank for under 18's") if emergency_phone_number.blank?
      end
    end
  
    def validate_years_attended
      unless years_attended.nil? || (years_attended == '')
        max_year = APP_CONFIG[:this_year] - APP_CONFIG[:first_year] + 1
        errors.add('years_attended', "should be between 1 and #{max_year}") unless years_attended.to_i >= 1 && years_attended.to_i <= max_year
      end
    end
  
    def find_or_create_participant
      normalize_first_name!
      normalize_surname!
  
      participant = Participant.find_by_first_name_and_surname_and_group_id(@first_name, @surname, @group_id)
  
      participant.nil? ? Participant.new : participant
    end
  
    def update_participant
      PARTICIPANT_ATTRIBUTES.each do |name|
        @participant.send("#{name}=", send(name))
      end
    end
  
    def find_or_create_user
      user = User.unscoped.participants.find_by_first_name_and_surname_and_email(@first_name, @surname, @email)
  
      if user.nil?
        user = User.new
        user.roles = ['participant']
      end
  
      user
    end
  
    def update_user
      USER_ATTRIBUTES.each do |name|
        @user.send("#{name}=", send(name))
      end
  
      if @user.new_record?
        @user.password = @user.password_confirmation = User.random_password
        @user.login = User.assign_login_name(@user.first_name, @user.surname)
        @user.group_name = @group.short_name if @group
      end
  
      @user.participant_id = @participant.id
    end
  
    def find_group
      Group.where(id: @group_id).first
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
  end
  