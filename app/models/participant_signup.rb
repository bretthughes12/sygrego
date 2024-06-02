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
                  :group_fee_category_id,
                  :coming,
                  :voucher_name,
                  :status,
                  :spectator,
                  :onsite,
                  :age,
                  :date_of_birth,
                  :gender,
                  :coming_friday,
                  :coming_saturday,
                  :coming_sunday,
                  :coming_monday,
                  :group_coord,
                  :helper,
                  :guest,
                  :address,
                  :suburb,
                  :postcode,
                  :phone_number,
                  :mobile_phone_number,
                  :email,
                  :years_attended,
                  :wwcc_number,
                  :medicare_number,
                  :medicare_expiry,
                  :medical_info,
                  :medications,
                  :dietary_requirements,
                  :allergies,
                  :emergency_contact,
                  :emergency_relationship,
                  :emergency_phone_number,
                  :emergency_email,
                  :driver,
                  :driving_to_syg,
                  :licence_type,
                  :number_plate,
                  :driver_signature,
                  :camping_preferences,
                  :sport_notes,
                  :participant,
                  :user,
                  :group,
                  :sport_preferences,
                  :new_user,
                  :login_name,
                  :login_email,
                  :disclaimer,
                  :booking_nbr,
                  :registration_nbr,
                  :early_bird,
                  :transfer_token
  
    INTEGER_FIELDS = %w[age].freeze
    DATE_FIELDS = %w[medicare_expiry(1i) date_of_birth(1i)].freeze
    DATE_IGNORE = %w[medicare_expiry(2i) medicare_expiry(3i) date_of_birth(2i) date_of_birth(3i)].freeze
  
    PARTICIPANT_ATTRIBUTES = [
      :first_name,
      :surname,
      :group_id,
      :group_fee_category_id,
      :coming,
      :status,
      :age,
      :date_of_birth,
      :onsite,
      :gender,
      :coming_friday,
      :coming_saturday,
      :coming_sunday,
      :coming_monday,
      :spectator,
      :group_coord,
      :helper,
      :guest,
      :address,
      :suburb,
      :postcode,
      :phone_number,
      :mobile_phone_number,
      :email,
      :years_attended,
      :wwcc_number,
      :medicare_number,
      :medicare_expiry, 
      :medical_info,
      :medications,
      :dietary_requirements,
      :allergies,
      :emergency_contact,
      :emergency_relationship,
      :emergency_phone_number,
      :emergency_email,
      :driver,
      :driving_to_syg,
      :licence_type,
      :number_plate,
      :driver_signature,
      :camping_preferences,
      :sport_notes
    ].compact
  
    TRANSFER_ATTRIBUTES = [
      :booking_nbr,
      :registration_nbr,
      :early_bird
    ]

    USER_ATTRIBUTES = {
      user_name: :name,
      address: :address,
      suburb: :suburb,
      postcode: :postcode,
      phone_number: :phone_number,
      user_email: :email
    }.freeze
  
    STATUSES = ['Requiring Approval',
                'Transfer pending',
                'Transferred',
                'Accepted'].freeze
  
    validates :password,               confirmation: true,
                                       length: { within: 5..40 },
                                       allow_nil: true
    validates :email,                  presence: true,
                                       length: { maximum: 100 },
                                       format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
                                       allow_blank: true,
                                       unless: proc { |o| o.email.blank? },
                                       message: 'invalid format' }
    validates :login_email,            length: { maximum: 100 },
                                       format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
                                       allow_blank: true,
                                       unless: proc { |o| o.login_email.blank? },
                                       message: 'invalid format' }
    validates :emergency_email,        length: { maximum: 100 },
                                       format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
                                       allow_blank: true,
                                       unless: proc { |o| o.emergency_email.blank? },
                                       message: 'invalid format' }
    validates :group_id,               presence: true
    validates :first_name,             presence: true,
                                       length: { maximum: 20 }
    validates :surname,                presence: true,
                                       length: { maximum: 20 }
    validates :login_name,             length: { maximum: 40 }
    validates :status,                 presence: true,
                                       inclusion: { in: STATUSES, message: 'status is invalid value' }
    validates :age,                    numericality: { only_integer: true },
                                       inclusion: { in: 0..130, message: 'should be between 0 and 130' },
                                       allow_blank: true
    validates :gender,                 presence: true,
                                       length: { maximum: 1 },
                                       inclusion: { in: %w[m f u M F U], message: "should be 'Male', 'Female' or 'Prefer not to say'" }
    validates :number_plate,           length: { maximum: 10 }
    validates :licence_type,           length: { maximum: 15 },
                                       inclusion: { in: Participant::LICENCE_TYPES }, 
                                       allow_blank: true
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
    validates :camping_preferences,    length: { maximum: 100 }
    validates :years_attended,         numericality: { only_integer: true },
                                       allow_blank: true
    validates :dietary_requirements,   presence: true,
                                       length: { maximum: 255 }
    validates :allergies,              presence: true,
                                       length: { maximum: 255 }
    validates :emergency_contact,      length: { maximum: 40 }
    validates :emergency_relationship, length: { maximum: 20 }
    validates :emergency_phone_number, length: { maximum: 20 }
  
    before_validation :calculate_age
    before_validation :validate_age_or_dob
    before_validation :validate_medicare_details
    before_validation :validate_emergency_contact_details
    before_validation :validate_wwcc_if_over_18
    before_validation :validate_driver_fields_if_driving
    before_validation :validate_email_provided
    before_validation :validate_disclaimer_ticked
  
    before_validation :normalize_first_name!
    before_validation :normalize_surname!
    before_validation :normalize_gender!
  
    def initialize(attributes = {})
      send_attributes(attributes)
      @participant = find_or_create_participant
      @user = find_or_create_user
      @group = find_group
    end
  
    def save
      if valid?
        update_participant
  
        if @participant.valid?
          @participant.save
        else
          @participant.errors.each do |key, value|
            errors.add key.to_s, value
          end
          return false
        end
  
        update_user

        if @user.new_record?
          @user.status = "Verified"
        end
  
        if @user.valid?
          @user.save
        else
          @user.errors.each do |key, value|
            errors.add key.to_s, value
          end
          false
        end
      else
        false
      end
    end
  
    def persisted?
      false
    end

    def name
      first_name + ' ' + surname
    end
  
    def user_name
      login_name.blank? ? name : login_name
    end

    def user_email
      login_email.blank? ? email : login_email
    end

    def send_attributes(attributes = {})
      attributes.each do |name, value|
        if INTEGER_FIELDS.include?(name)
          value = value.to_i
        elsif DATE_FIELDS.include?(name)
          name = name.partition("(")[0]
          value = construct_date(name, attributes)
        else
          value = value.strip if value.respond_to?(:strip)
        end

        unless DATE_IGNORE.include?(name)
          send("#{name}=", value)
        end
      end
    end
  
    private
  
    def validate_age_or_dob
      if @group.mysyg_setting.collect_age_by == "Age"
        errors.add(:age, "can't be blank") if age.blank?
      else
        errors.add(:date_of_birth, "can't be blank") if date_of_birth.nil?
      end
    end
  
    def validate_emergency_contact_details
      if (age && age.to_i < 18) || @group.mysyg_setting.require_emerg_contact
        errors.add(:emergency_contact, "can't be blank") if emergency_contact.blank?
        errors.add(:emergency_relationship, "can't be blank") if emergency_relationship.blank?
        errors.add(:emergency_phone_number, "can't be blank") if emergency_phone_number.blank?
        errors.add(:emergency_email, "can't be blank") if emergency_email.blank?
      end
    end
  
    def validate_medicare_details
      if @group.mysyg_setting.require_medical
        errors.add(:medicare_number, "can't be blank") if medicare_number.blank?
        errors.add(:medicare_expiry, "can't be blank") if medicare_expiry.blank?
      end
    end
  
    def validate_wwcc_if_over_18
      if age && age.to_i >= 18
        errors.add(:wwcc_number, "can't be blank for over 18's") if wwcc_number.blank?
      end
    end
  
    def validate_driver_fields_if_driving
      if driver == "1"
        errors.add(:licence_type, "can't be blank for drivers") if licence_type.blank?
        errors.add(:number_plate, "can't be blank for drivers") if number_plate.blank?
        errors.add(:driver_signature, "must be ticked for drivers") if driver_signature == "0"
      end
    end
  
    def validate_email_provided
      errors.add(:login_email, "must be provided for your user login") if email.blank? && login_email.blank?
    end

    def validate_disclaimer_ticked
      errors.add(:disclaimer, "must be ticked") if disclaimer == "0"
    end

    def validate_voucher_name
      unless voucher_name.blank?
        name = voucher_name
        name.upcase!
        @voucher = Voucher.find_by_name(name)
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

      validate_voucher_name
      if @voucher && @voucher.valid_for?(@participant)
        @participant.voucher = @voucher
      end
    end
  
    def find_or_create_user
      user = User.find_by_email(user_email)
  
      if user.nil?
        user = User.new
      end
  
      role = Role.find_by_name("participant")
      user.roles << role unless user.role?(:participant)

      user
    end
  
    def update_user
      @new_user = @user.new_record?

      if @user.new_record?
        USER_ATTRIBUTES.each do |name, model_name|
          @user.send("#{model_name}=", send(name))
        end
    
        @user.status = 'Approved'
        @user.password = @user.password_confirmation = User.random_password
      end
  
      @user.participants << @participant unless @user.participants.include?(@participant)
    end
  
    def find_group
      Group.where(id: @group_id).first
    end

    def construct_date(name, attributes)
      year_attribute = eval("\"#{name}(1i)\"")
      year = eval("\"#{attributes[year_attribute.to_sym]}\"")
      month_attribute = eval("\"#{name}(2i)\"")
      month = eval("\"#{attributes[month_attribute.to_sym]}\"")
      day_attribute = eval("\"#{name}(3i)\"")
      day = eval("\"#{attributes[day_attribute.to_sym]}\"")

      if year == "" || month == "" || day == ""
        nil
      else
        "#{year}-#{month}-#{day}".to_date
      end
    end 

    def calculate_age
      if age.nil? && !date_of_birth.nil?
        s = Setting.first
        @age = s.first_day_of_syg.year - date_of_birth.year
        @age -= 1 if s.first_day_of_syg < date_of_birth + @age.years
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
  end
  