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
                  :church_rep,
                  :years_attended,
                  :group_changes,
                  :ministry_goal,
                  :attendee_profile,
                  :buddy_interest,
                  :buddy_comments,
                  :gc_role,     
                  :gc_decision,      
                  :gc_years_attended_church,  
                  :gc_thoughts,
                  :disclaimer,
                  :ccvt_child_safe_disclaimer,
                  :wwcc_policy_disclaimer,
                  :conduct_disclaimer,
                  :group_child_safe_disclaimer,
                  :info_acknowledgement,
                  :followup_requested
  
    INTEGER_FIELDS = %w[years_as_gc 
      id 
      years_attended
      gc_years_attended_church
    ].freeze
  
    GROUP_ATTRIBUTES = %i[
      name
      address
      suburb
      postcode
      phone_number
      email
      website
      denomination
      years_attended
      group_changes
      ministry_goal
      attendee_profile
      gc_role
      gc_decision
      gc_years_attended_church
      gc_thoughts
      disclaimer
      ccvt_child_safe_disclaimer
      wwcc_policy_disclaimer
      conduct_disclaimer
      group_child_safe_disclaimer
      info_acknowledgement
      followup_requested
    ].freeze
  
    EVENT_DETAIL_ATTRIBUTES = %i[
      buddy_interest
      buddy_comments
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
    validates :denomination,           presence: true,
                                       length: { maximum: 40 }
    validates :years_attended,         numericality: { only_integer: true },
                                       allow_blank: true
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
    validates :gc_reference_phone,     presence: true,
                                       length: { maximum: 30 }
    validates :years_as_gc,            numericality: { only_integer: true },
                                       allow_blank: true
    validates :gc_years_attended_church,
                                       numericality: { only_integer: true },
                                       allow_blank: true
    validates :buddy_interest,         length: { maximum: 50 },
                                       inclusion: { in: EventDetail::BUDDY_INTEREST }
  
    before_validation :normalize_church_rep_name!
    before_validation :normalize_gc_name!
    before_validation :validate_group_has_not_registered
    before_validation :validate_different_email_for_church_rep_and_gc
    before_validation :validate_info_acknowledgement_ticked
    before_validation :validate_ccvt_child_safe_disclaimer_ticked
    before_validation :validate_wwcc_disclaimer_ticked
    before_validation :validate_conduct_disclaimer_ticked
    before_validation :validate_disclaimer_ticked
    before_validation :validate_group_child_safe_disclaimer_ticked
  
    def initialize(attributes = {})
      send_attributes(attributes)
      @group = find_or_create_group
      @event_detail = @group.event_detail || EventDetail.new(group: @group)
      @church_rep = find_or_create_church_rep
      @gc = find_or_create_gc
    end
  
    def save
      if valid?
        update_group
        @group.status = 'Submitted'
  
        if @group.valid?
          @group.save
        else
          @group.errors.each do |key, value|
            errors.add key.to_s, value
          end
          # puts 'Group errors:'
          # pp @group.errors
          return false
        end

        update_event_detail

        if @event_detail.valid?
          @event_detail.save
        else
          @event_detail.errors.each do |key, value|
            errors.add key.to_s, value
          end
          # puts 'Event Detail errors:'
          # pp @event_detail.errors
          return false
        end

        update_church_rep
  
        if @church_rep.valid?
          @church_rep.save
        else
          # puts 'Church Rep errors:'
          # pp @church_rep.errors
          return false
        end
        @group.status = 'Submitted'

        update_gc
  
        if @gc.valid?
          @gc.save
        else
          # puts 'GC errors:'
          # pp @gc.errors
          return false
        end
      else
        return false
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
  
    private
  
    def validate_group_has_not_registered
      if @group.status != 'Stale'
        errors.add(:name, 'group has already been registered. Please email info@stateyouthgames.com')
      end
    end
  
    def validate_different_email_for_church_rep_and_gc
      if @gc_email == @church_rep_email
        errors.add(:gc_name, '/ email cannot be the same as the Church Representative')
      end
    end

    def validate_info_acknowledgement_ticked
      errors.add(:info_acknowledgement, "must be ticked") if info_acknowledgement == "0"
    end

    def validate_ccvt_child_safe_disclaimer_ticked
      errors.add(:ccvt_child_safe_disclaimer, "must be ticked") if ccvt_child_safe_disclaimer == "0"
    end

    def validate_wwcc_disclaimer_ticked
      errors.add(:wwcc_policy_disclaimer, "must be ticked") if wwcc_policy_disclaimer == "0"
    end

    def validate_conduct_disclaimer_ticked
      errors.add(:conduct_disclaimer, "must be ticked") if conduct_disclaimer == "0"
    end

    def validate_disclaimer_ticked
      errors.add(:disclaimer, "must be ticked") if disclaimer == "0"
    end

    def validate_group_child_safe_disclaimer_ticked
      errors.add(:group_child_safe_disclaimer, "must be ticked") if group_child_safe_disclaimer == "0"
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
  
    def update_event_detail
      EVENT_DETAIL_ATTRIBUTES.each do |name|
        @event_detail.send("#{name}=", send(name))
      end
    end
  
    def update_church_rep
      CHURCH_REP_ATTRIBUTES.each do |name, model_name|
        @church_rep.send("#{model_name}=", send(name))
      end
  
      @church_rep.status = 'Not Verified'
      @church_rep.password = @church_rep.password_confirmation = User.random_password
      @church_rep.groups << @group unless @church_rep.groups.include?(@group)
    end
  
    def update_gc
      GC_ATTRIBUTES.each do |name, model_name|
        @gc.send("#{model_name}=", send(name))
      end
  
      @gc.status = 'Nominated'
      @gc.password = @gc.password_confirmation = User.random_password
      @gc.groups << @group unless @gc.groups.include?(@group)
    end
  
    def normalize_church_rep_name!
      self.church_rep_name = church_rep_name.titleize if church_rep_name
    end
  
    def normalize_gc_name!
      self.gc_name = gc_name.titleize if gc_name
    end
end