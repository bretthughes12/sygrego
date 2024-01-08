# == Schema Information
#
# Table name: volunteers
#
#  id                :bigint           not null, primary key
#  collected         :boolean          default(FALSE)
#  description       :string(100)      not null
#  details_confirmed :boolean          default(FALSE)
#  email             :string(40)
#  equipment_in      :string
#  equipment_out     :string
#  lock_version      :integer          default(0)
#  mobile_confirmed  :boolean          default(FALSE)
#  mobile_number     :string(20)
#  notes             :text
#  returned          :boolean          default(FALSE)
#  t_shirt_size      :string(10)
#  updated_by        :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  participant_id    :bigint
#  section_id        :bigint
#  session_id        :bigint
#  volunteer_type_id :bigint
#
# Indexes
#
#  index_volunteers_on_participant_id     (participant_id)
#  index_volunteers_on_volunteer_type_id  (volunteer_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (volunteer_type_id => volunteer_types.id)
#
class Volunteer < ApplicationRecord
    include Auditable
    include Searchable

    require 'csv'

    has_and_belongs_to_many :sections
    belongs_to :volunteer_type
    belongs_to :session, optional: true
    belongs_to :participant, optional: true
  
    scope :filled, -> { where('participant_id is not null') }
    scope :unfilled, -> { where('participant_id is null') }
    scope :sport_related, -> { where('volunteer_types.sport_related' => true).includes(:volunteer_type).references(:volunteer_type) }
    scope :cleaning_roster, -> { where("volunteer_types.name in ('Toilet Cleaning Roster', 'Hall Cleaning', 'Grounds Cleanup')").includes(:volunteer_type).references(:volunteer_type) }
    scope :cleaners, -> { where('volunteer_types.name' => 'Toilet Cleaning Roster').includes(:volunteer_type).references(:volunteer_type) }
    scope :security, -> { where('volunteer_types.name' => 'Usher').includes(:volunteer_type).references(:volunteer_type) }
    scope :village, -> { where('volunteer_types.name' => 'Village Helper').includes(:volunteer_type).references(:volunteer_type) }
    scope :sport_coords, -> { where('volunteer_types.name' => 'Sport Coordinator').includes(:volunteer_type).references(:volunteer_type) }
    scope :marshals, -> { where('volunteer_types.name' => 'Marshal').includes(:volunteer_type).references(:volunteer_type) }
    scope :timekeepers, -> { where('volunteer_types.name' => 'Timekeeper').includes(:volunteer_type).references(:volunteer_type) }
    scope :first_aid, -> { where('volunteer_types.name' => 'First Aider').includes(:volunteer_type).references(:volunteer_type) }
    scope :umpires, -> { where('volunteer_types.name' => 'Umpire').includes(:volunteer_type).references(:volunteer_type) }
    scope :saturday, -> { where("sessions.name like 'Saturday%'").includes(:session).references(:session) }
    scope :sunday, -> { where("sessions.name like 'Sunday%'").includes(:session).references(:session) }
  
    delegate :t_shirt,
             :age_category,
             :min_age, to: :volunteer_type
  
    T_SHIRT_SIZES = %w[XS S M L
                       XL XXL XXXL].freeze
  
    EQUIPMENT_OUT_OPTIONS = ['Equipment given',
                             'Equipment to be collected at venue'].freeze
    EQUIPMENT_IN_OPTIONS  = ['Equipment returned',
                             'Equipment left at venue'].freeze
  
    validates :description,            presence: true,
                                       length: { maximum: 100 }
    validates :email,                  length: { maximum: 40 }
    validates :email,                  format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, message: 'invalid format' },
                                       allow_blank: true,
                                       unless: proc { |o| o.email.blank? }
    validates :mobile_number,          length: { maximum: 20 }
    validates :volunteer_type_id,      presence: true,
                                       numericality: { only_integer: true }
    validates :t_shirt_size,           length: { maximum: 10 },
                                       inclusion: { in: T_SHIRT_SIZES },
                                       allow_blank: true
    validates :equipment_out,          length: { maximum: 255 },
                                       inclusion: { in: EQUIPMENT_OUT_OPTIONS },
                                       allow_blank: true
    validates :equipment_in,           length: { maximum: 255 },
                                       inclusion: { in: EQUIPMENT_IN_OPTIONS },
                                       allow_blank: true
  
    after_create :check_participant_on_create
    after_update :check_participants_on_update
    after_destroy :check_participant_on_destroy

    searchable_by 'volunteers.description'
  
    def venue_name
        if sections.empty?
          '(not venue-specific)'
        else
          sections.first.venue_name
        end
    end
    
    def session_name
        if session
          session.name
        elsif sections.empty?
          '(not session-specific)'
        else
          sections.first.session_name
        end
    end
    
    def participant_name
      if participant
        participant.name
      else
        ''
      end
    end
      
    def group
      if participant
        participant.group
      else
        nil
      end
    end
  
    def group_short_name
      if participant
        participant.group.short_name
      else
        ''
      end
    end
    
    def saturday?
      session_name =~ /^Saturday.*/
    end
    
    def sunday?
      session_name =~ /^Sunday.*/
    end

    def self.sport_coords_saturday
        coords = []
        sport_coords.order('volunteers.description').each do |o|
          coords << o if o.saturday?
        end
        coords
    end
    
    def self.sport_coords_sunday
        coords = []
        sport_coords.order('volunteers.description').each do |o|
          coords << o if o.sunday?
        end
        coords
    end
   
    def self.sport_volunteers
        volunteers = []
        sport_related.order('volunteers.description').each do |o|
          volunteers << o
        end
        volunteers.sort_by(&:name)
    end
    
    def number_of_teams
        if sections.empty?
          nil
        else
          sections.first.number_of_teams
        end
    end

    def sport_name
        if sections.empty?
          description
        else
          sections.first.sport_name
        end
    end
    
    def sport
        if sections.empty?
          nil
        else
          sections.first.sport
        end
    end
    
    def name
        if sections.empty?
          description
        else
          sections.first.name
        end
    end
    
    def mobile_phone_number
      if mobile_number.present?
        Participant.normalize_phone_number(mobile_number)
      elsif participant && participant.mobile_phone_number.present?
        participant.mobile_phone_number
      end
    end
   
    def email_recipients
      if email.blank? 
        if participant
          participant.email
        end
      else
        email
      end
    end

    def self.import(file, user)
      creates = 0
      updates = 0
      errors = 0
      error_list = []

      CSV.foreach(file.path, headers: true) do |fields|
        volunteer = fields[0].nil? ? nil : Volunteer.find_by_id(fields[0].to_i)
        type = fields[1].nil? ? nil : VolunteerType.find_by_database_code(fields[1])
        section = fields[3].nil? ? nil : Section.find_by_name(fields[3])
        session = fields[4].nil? ? nil : Session.find_by_name(fields[4])
        participant = fields[5].nil? ? nil : Participant.find_by_id(fields[5].to_i)

        if volunteer

          volunteer.volunteer_type = type
          volunteer.sections << section unless section.nil? || volunteer.sections.include?(section)
          volunteer.session = session
          volunteer.participant = participant
          volunteer.description = fields[2]
          volunteer.email = fields[8]
          volunteer.mobile_number = fields[9]
          volunteer.t_shirt_size = fields[10]
          volunteer.updated_by = user.id
          
          if volunteer.save
            updates += 1
          else
            errors += 1
            error_list << volunteer
          end
        else
          volunteer = Volunteer.create(
              volunteer_type: type,
              session:        session,
              participant:    participant,
              description:    fields[2],
              email:          fields[8],
              mobile_number:  fields[9],
              t_shirt_size:   fields[10],
              updated_by:     user.id
          )
          volunteer.sections << section unless section.nil?

          if volunteer.errors.empty?
            creates += 1
          else
            errors += 1
            error_list << session
          end
        end
      end
  
      { creates: creates, updates: updates, errors: errors, error_list: error_list }
    end
  
    private

    def self.sync_fields
      ['description',
        'session_id',
        'participant_id',
        'volunteer_type_id']
    end

    def check_participant_on_create
      if self.participant
        update_participant_category!(self.volunteer_type, self.participant)
      end
    end

    def check_participants_on_update
      if self.participant_id_previously_changed?
        if self.participant_id_previously_was
          old_participant = Participant.where(id: self.participant_id_previously_was).first
          if old_participant
            revert_participant_category!(old_participant) unless old_participant.nil?
          end
        end
  
        if self.participant
          update_participant_category!(self.volunteer_type, self.participant)
        end
      end
    end

    def check_participant_on_destroy
      if self.participant
        revert_participant_category!(self.participant)
      end
    end

    def update_participant_category!(volunteer_type, participant)
      case
      when volunteer_type.name == "Sport Coordinator"
        participant.sport_coord = true
        participant.save(validate: false)
      end
    end
  
    def revert_participant_category!(participant)
      coords = participant.volunteers.sport_coords.where.not(id: self.id).load
      case
      when coords.empty?
        participant.sport_coord = false
        participant.save(validate: false)
      end
    end
  
end
