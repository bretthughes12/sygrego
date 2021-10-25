# frozen_string_literal: true

class GroupSignup
    extend ActiveModel::Callbacks
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    include ActiveModel::Conversion
    extend ActiveModel::Naming
  
    require 'pp'

    attr_accessor :id,
                  :name,
                  :address,
                  :suburb,
                  :postcode,
                  :phone_number,
                  :email,
                  :website,
                  :denomination,
                  :church_rep_name,
                  :church_rep_role,
                  :church_rep_address,
                  :church_rep_suburb,
                  :church_rep_postcode,
                  :church_rep_phone_number,
                  :church_rep_email,
                  :church_rep_wwcc_number,
                  :gc_name,
                  :gc_address,
                  :gc_suburb,
                  :gc_postcode,
                  :gc_phone_number,
                  :gc_email,
                  :gc_wwcc_number,
                  :gc_reference,
                  :gc_reference_phone,
                  :years_as_gc,
                  :group,
                  :gc,
                  :church_rep
  
    INTEGER_FIELDS = %w[years_as_gc id].freeze
  
    GROUP_ATTRIBUTES = %i[
      name
      address
      suburb
      postcode
      phone_number
      email
      website
      denomination
    ].freeze
  
    CHURCH_REP_ATTRIBUTES = {
      church_rep_name: :name,
      church_rep_role: :group_role,
      church_rep_address: :address,
      church_rep_suburb: :suburb,
      church_rep_postcode: :postcode,
      church_rep_phone_number: :phone_number,
      church_rep_email: :email,
      church_rep_wwcc_number: :wwcc_number
    }.freeze
  
    GC_ATTRIBUTES = {
      gc_name: :name,
      gc_address: :address,
      gc_suburb: :suburb,
      gc_postcode: :postcode,
      gc_phone_number: :phone_number,
      gc_email: :email,
      gc_wwcc_number: :wwcc_number,
      gc_reference: :gc_reference,
      gc_reference_phone: :gc_reference_phone,
      years_as_gc: :years_as_gc
    }.freeze
  
    validates :id,                     numericality: { only_integer: true },
                                       allow_blank: true
    validates :name,                   length: { maximum: 100 }
    validates :address,                presence: true,
                                       length: { maximum: 200 }
    validates :suburb,                 presence: true,
                                       length: { maximum: 40 }
    validates :postcode,               presence: true,
                                       numericality: { only_integer: true }
    validates :phone_number,           presence: true,
                                       length: { maximum: 20 }
    validates :email,                  presence: true,
                                       length: { maximum: 100 },
                                       format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
                                                 message: 'invalid format' }
    validates :website,                length: { maximum: 100 }
    validates :denomination,           length: { maximum: 40 }
    validates :church_rep_name,        presence: true,
                                       length: { maximum: 40 }
    validates :church_rep_role,        presence: true,
                                       length: { maximum: 100 }
    validates :church_rep_address,     presence: true,
                                       length: { maximum: 200 }
    validates :church_rep_suburb,      presence: true,
                                       length: { maximum: 40 }
    validates :church_rep_postcode,    presence: true,
                                       numericality: { only_integer: true }
    validates :church_rep_phone_number,
              presence: true,
              length: { maximum: 20 }
    validates :church_rep_email,       presence: true,
                                       length: { maximum: 100 },
                                       format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
                                                 message: 'invalid format' }
    validates :church_rep_wwcc_number, presence: true,
                                       length: { maximum: 20 }
    validates :gc_name,                presence: true,
                                       length: { maximum: 40 }
    validates :gc_address,             presence: true,
                                       length: { maximum: 200 }
    validates :gc_suburb,              presence: true,
                                       length: { maximum: 40 }
    validates :gc_postcode,            presence: true,
                                       numericality: { only_integer: true }
    validates :gc_phone_number,        presence: true,
                                       length: { maximum: 20 }
    validates :gc_email,               presence: true,
                                       length: { maximum: 100 },
                                       format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
                                                 message: 'invalid format' }
    validates :gc_wwcc_number,         presence: true,
                                       length: { maximum: 20 }
    validates :gc_reference,           presence: true,
                                       length: { maximum: 40 }
    validates :gc_reference_phone,
              presence: true,
              length: { maximum: 30 }
    validates :years_as_gc,            numericality: { only_integer: true },
                                       allow_blank: true
  
    before_validation :normalize_church_rep_name!
    before_validation :normalize_gc_name!
    before_validation :validate_group_has_not_registered
  
    def initialize(attributes = {})
      send_attributes(attributes)
      @group = find_or_create_group
      @church_rep = find_or_create_church_rep
      @gc = find_or_create_gc
    end
  
    def update_attributes(attributes = {})
      send_attributes(attributes)
      save
    end
  
    def save
      if valid?
        update_group
  
        if @group.valid?
          @group.save
        else
          @group.errors.each do |key, value|
            errors.add key, value
          end
          return false
        end
  
        update_church_rep
  
        if @church_rep.valid?
          @church_rep.save
        else
          error_map = CHURCH_REP_ATTRIBUTES.invert
          @church_rep.errors.each do |key, value|
            errors.add error_map[key.to_sym], value
          end
          false
        end
  
        update_gc
  
        if @gc.valid?
          @gc.save
        else
          error_map = GC_ATTRIBUTES.invert
          @gc.errors.each do |key, value|
            errors.add error_map[key.to_sym], value
          end
          false
        end
      else
        false
      end
    end
  
    def save!
      update_group
      @group.save!
  
      update_church_rep
      @church_rep.save!
  
      update_gc
      @gc.save!
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
  
    private
  
    def validate_group_has_not_registered
      if @group.status != 'Stale'
        errors.add(:name, 'group has already been registered. Please email info@stateyouthgames.com')
      end
    end
  
    def find_or_create_group
      group = Group.find(@id) if @id && !@id.zero?
      if group.nil?
        group = Group.find_by_name(@name)
      else
        @name = group.name if @name.blank?
      end
  
      group.nil? ? Group.new : group
    end
  
    def find_or_create_church_rep
      church_rep = User.find_by_email(@church_rep_email)
  
      if church_rep.nil?
        church_rep = User.new
      end
  
      role = Role.find_by_name("church_rep")
      church_rep.roles << role unless church_rep.role?(:church_rep)

      church_rep
    end
  
    def find_or_create_gc
      gc = User.find_by_email(@gc_email)
  
      if gc.nil?
        gc = User.new
      end
  
      gc.primary_gc = true
      role = Role.find_by_name("gc")
      gc.roles << role unless gc.role?(:gc)
  
      gc
    end
  
    def update_group
      GROUP_ATTRIBUTES.each do |name|
        @group.send("#{name}=", send(name))
      end
  
      @group.status = 'Submitted'
  
      if @group.new_record?
        @group.short_name = Group.assign_short_name(@group.name)
        @group.abbr = Group.assign_abbr(@group.name)
        @group.trading_name = @group.name
      else
        @group.short_name = Group.assign_short_name(@group.name) if @group.errors.include?(:short_name)
        @group.abbr = Group.assign_abbr(@group.name) if @group.errors.include?(:abbr)
        @group.trading_name = @group.name if @group.errors.include?(:trading_name)
      end
    end
  
    def update_church_rep
      CHURCH_REP_ATTRIBUTES.each do |name, model_name|
        @church_rep.send("#{model_name}=", send(name))
      end
  
#      @church_rep.status = 'Not Verified'
#      @church_rep.stale = false
#      @church_rep.active = true
      @church_rep.password = @church_rep.password_confirmation = User.random_password
#      @church_rep.reset_password = true
      @church_rep.groups << @group unless @church_rep.groups.include?(@group)
    end
  
    def update_gc
      GC_ATTRIBUTES.each do |name, model_name|
        @gc.send("#{model_name}=", send(name))
      end
  
#      @gc.status = 'Nominated'
#      @gc.stale = false
#      @gc.active = true
      @gc.password = @gc.password_confirmation = User.random_password
#      @gc.reset_password = true
#      @gc.generate_one_time_login_token!
      @gc.groups << @group unless @gc.groups.include?(@group)
    end
  
    def normalize_church_rep_name!
      self.church_rep_name = church_rep_name.titleize if church_rep_name
    end
  
    def normalize_gc_name!
      self.gc_name = gc_name.titleize if gc_name
    end
  end
  