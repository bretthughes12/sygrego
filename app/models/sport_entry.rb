# == Schema Information
#
# Table name: sport_entries
#
#  id                   :bigint           not null, primary key
#  chance_of_entry      :integer          default(100)
#  group_number         :integer          default(1)
#  multiple_teams       :boolean          default(FALSE)
#  status               :string(20)       default("Requested")
#  team_number          :integer          default(1), not null
#  updated_by           :bigint
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  captaincy_id         :bigint
#  grade_id             :bigint           not null
#  group_id             :bigint           not null
#  preferred_section_id :bigint
#  section_id           :bigint
#
# Indexes
#
#  index_sport_entries_on_grade_id  (grade_id)
#  index_sport_entries_on_group_id  (group_id)
#
# Foreign Keys
#
#  fk_rails_...  (grade_id => grades.id)
#  fk_rails_...  (group_id => groups.id)
#

class SportEntry < ApplicationRecord
  include Comparable
  include Enumerable
  include Auditable

  belongs_to :group
  belongs_to :grade
  belongs_to :section, optional: true
  belongs_to :captaincy, class_name: 'Participant', optional: true
  has_many   :participants_sport_entries
  has_many   :participants, through: :participants_sport_entries

  scope :entered, -> { where(status: 'Entered') }
  scope :requested, -> { where(status: 'Requested') }
  scope :not_waiting, -> { where.not(status: 'Waiting List') }
  scope :waiting_list, -> { where(status: 'Waiting List') }
  scope :to_be_confirmed, -> { where(status: 'To Be Confirmed') }
  scope :without_section, -> { where("section_id is NULL") }

  delegate :draw, to: :section
  delegate :grade_type,
           :sport,
           :session_name,
           :eligible_to_participate?,
           :sport_preferences,
           :team_size, to: :grade

  before_validation :validate_number_of_entries_in_sport, on: :create
  after_create :update_team_numbers
  after_create :update_grade_flags
  after_create :check_waiting_list
  after_create :check_sport_draw_addition_emails
  after_update :update_grade_flags_on_status_change
  before_destroy :check_sport_entry_emails
  before_destroy :check_sport_draw_withdrawal_emails
  before_destroy :remove_participants_from_entry!
  after_destroy :update_team_numbers
  after_destroy :update_grade_flags
  after_destroy :check_waiting_list

  STATUSES = ['Requested',
    'To Be Confirmed',
    'Entered',
    'Waiting List'].freeze

  validates :status, 
    presence: true,
    length: { maximum: 20 },
    inclusion: { in: STATUSES }
  validates :grade_id,         
    presence: true
  validates :group_id,               
    presence: true
  validates :group_number,
    numericality: { only_integer: true }
  validates :team_number,            
    presence: true,
    numericality: { only_integer: true },
    allow_blank: true
  validates :preferred_section_id,            
    numericality: { only_integer: true },
    allow_blank: true

#  validate :validate_if_entry_can_be_deleted, on: :destroy

  def <=>(other)
    if other
      if grade == other.grade
        id <=> other.id
      else
        grade <=> other.grade
      end
    end
  end

  def cached_grade
    @grade ||= grade
  end

  def cached_participants
    @participants ||= participants
  end

#  def sport_id
#    cached_grade.nil? ? 0 : cached_grade.sport.id
#  end

  def name
    if cached_grade.grade_type == 'Singles'
      number_of_participants > 0 ? cached_participants[0].name : 'Add a participant'
    else
      if cached_grade.grade_type == 'Doubles'
        number_of_participants > 1 ? cached_participants[0].name + ' / ' + cached_participants[1].name : 'Add participant(s)'
      else
        if cached_grade.grade_type == 'Team'
          multiple_teams ? "#{group.short_name} #{team_number}" : group.short_name
        end
      end
    end
  end

  def team_text
    group.abbr + " #{team_number}"
  end

  def draw_text
    group.abbr + "(#{team_number})"
  end

  def number_of_participants
    @number_of_participants ||= cached_participants.count
  end

  def section_name
    section.nil? ? cached_grade.name : section.name
  end

  def allocated_section_name
    section.nil? ? "" : section.name
  end

  def preferred_section_name
    if preferred_section_id.nil? 
      "" 
    else
      section = Section.where(id: preferred_section_id).first
      if section.nil?
        ""
      else
        section.name 
      end
    end
  end

  def requires_participants?
    number_of_participants < cached_grade.min_participants
  end

  def requires_males?
    cached_participants.males.count < cached_grade.min_males
  end

  def requires_females?
    cached_participants.females.count < cached_grade.min_females
  end

  def can_take_participants?
    number_of_participants < cached_grade.max_participants
  end

  def issues
    issues = []
    issues << 'Not enough females' if requires_females?
    issues << 'Not enough males' if requires_males?
    issues << 'Not enough participants' if requires_participants?
    issues
  end

  def venue_known?
    if section
      true
    elsif cached_grade
      cached_grade.possible_venues.size == 1
      # else no action
    end
  end

  def venue_name
    if section
      section.venue_name
    elsif cached_grade
      cached_grade.venue_name
      # else no action
    end
  end

#  def venue
#    if section
#      section.sport_venue
#    elsif cached_grade
#      cached_grade.possible_venues[0]
      # else no action
#    end
#  end

def session_known?
  if section
    true
  elsif cached_grade
    cached_grade.possible_sessions.size == 1
    # else no action
  end
end

def session_name
  if section
    section.session_name
  elsif cached_grade
    cached_grade.session_name
    # else no action
  end
end

#  def session
#    if section
#      section.session
#    elsif cached_grade
#      cached_grade.possible_sessions[0]
    # else no action
#    end
#  end

  def high_priority
    total_entries = self.group.sport_entries.where(grade: self.grade).order(:id)
    false if total_entries.count == 1
    self.id == total_entries.first.id
  end

  def entry_can_be_deleted(settings)
    !draw_complete(settings) ||
      cached_grade.status == 'Open' ||
      status == 'Waiting List'
  end

  def allocation_factor
    @ac ||= AllocationCalculation.new(self)
    @ac.allocation_factor
  end

  def allocation_chance
    @ac ||= AllocationCalculation.new(self)
    limit = cached_grade.entries_to_be_allocated

    if status == 'Entered'
      100

      # already missed out
    elsif status == 'Waiting List'
      0

      # all entries for this grade have been allocated
    elsif limit < 1
      0

      # the grade has not reached its limit yet
    elsif cached_grade.sport_entries.requested.count <= limit
      100

      # there are enough spots to be allocated for each group to have one (groups
      # wanting more than one go into a ballot)
    elsif @ac.number_of_groups_in_sport_grade < limit
      if high_priority
        100
      else
        @ac.high_priority = false
        @ac.allocation_chance
      end
        
      # there are exactly enough spots to be allocated for each group to have one,
      # so all second (and third, etc) entries automatically miss out
    elsif @ac.number_of_groups_in_sport_grade == limit
      if high_priority
        100
      else
        0
      end

      # there are not enough spots for one for each church, so all second (and third, etc)
      # entries automatically miss out and first entries go into the ballot
    else
      if high_priority
        @ac.high_priority = true
        @ac.allocation_chance
      else
        0
      end
    end
  end

  def available_sport_preferences
    sport.sport_preferences(group).reject do |p|
      p.preference.nil? ||
        participants.include?(p.participant) ||
        p.group != group ||
        !p.participant.coming ||
        p.participant.spectator ||
        !p.participant.can_play_grade(cached_grade)
    end
  end

  def reset!
    self.status = 'Requested'
    save
  end

  def enter!
    self.status = 'Entered'
    save
    group.reset_allocation_bonus!
  end

  def require_confirmation!
    self.status = 'To Be Confirmed'
    save
    group.reset_allocation_bonus!
    grade.update_for_change_in_entries
  end

  def reject!
    self.status = 'Waiting List'
    save
    group.increment_allocation_bonus!
  end

  def assign_section!
    check_for_only_section! if self.section.nil?
    check_and_assign_preferred_section! if self.section.nil?
    check_and_assign_sport_coord_section! if self.section.nil?
  end

  def check_for_only_section!
    if self.grade.sections.count == 1
      self.section = self.grade.sections.first
      save
    end
  end

  def check_and_assign_preferred_section!
    unless self.preferred_section_id.nil?
      s = Section.where(id: self.preferred_section_id).first
    end
    
    if s && s.can_take_more_entries?
      self.section = s
      save
    end
  end

  def check_and_assign_sport_coord_section!
    grade.sections.active.each do |s|
      s.sport_coords.each do |v|
        if v.participant && v.participant.group == group
          self.section = s
          save
        end
      end
    end
  end

  def self.import(file, user)
    creates = 0
    updates = 0
    errors = 0
    error_list = []

    CSV.foreach(file.path, headers: true) do |fields|
      group = Group.find_by_short_name(fields[5].to_s)
      if group.nil?
        group = Group.find_by_short_name("No group")
      end

      grade = Grade.find_by_name(fields[2].to_s)
      grade_id = grade.id if grade
      section = Section.find_by_name(fields[3].to_s)
      section_id = section.id if section
      preferred_section = Section.find_by_name(fields[4].to_s)
      preferred_section_id = preferred_section.id if preferred_section

      if grade
        sport_entry = SportEntry.where(grade_id: grade.id, team_number: fields[9].to_i).first
      end

      if sport_entry
        sport_entry.section_id                = section_id
        sport_entry.preferred_section_id      = preferred_section_id
        sport_entry.group_id                  = group.id 
        sport_entry.status                    = fields[7]
        sport_entry.group_number              = fields[10].to_i

        if sport_entry.save
          updates += 1
        else
          errors += 1
          error_list << sport_entry
        end
      else
        sport_entry = SportEntry.create(
          grade_id:                grade_id,
          section_id:              section_id,
          preferred_section_id:    preferred_section_id,
          group_id:                group.id,
          status:                  fields[7],
          team_number:             fields[9].to_i,
          group_number:            fields[10].to_i,
          updated_by:              user.id)

        if sport_entry.errors.empty?
            creates += 1
        else
            errors += 1
            error_list << sport_entry
        end
      end
    end

    { creates: creates, updates: updates, errors: errors, error_list: error_list }
end

private

  def validate_number_of_entries_in_sport
    if cached_grade && cached_grade.sport.group_entries(group) >= cached_grade.sport.max_entries_group
      errors.add(:grade_id, 'too many entries in this sport')
    end
  end

#  Cannot work, as calls entry_can_be_deleted without 'settings' parameter
#  def validate_if_entry_can_be_deleted
#    unless entry_can_be_deleted
#      errors.add(:base, 'Sport grade is closed - deletion is not allowed')
#    end
#  end

  def draw_complete(settings)
    if cached_grade.sport.classification == 'Team'
      settings.team_draws_complete
    else
      settings.indiv_draws_complete
    end
  end

  def update_team_numbers
    self.group.update_team_numbers(grade)
  end

  def update_grade_flags
    self.grade.update_for_change_in_entries
  end

  def update_grade_flags_on_status_change
    if status_changed?
      self.grade.update_for_change_in_entries
    end
  end

  def check_sport_entry_emails
    # Send an email if a team has withdrawn from a closed, full Restricted sport section
    if (self.status == "To Be Confirmed" || self.status == "Entered") && 
      self.grade.status != "Open" &&
      self.grade.entry_limit && 
      self.grade.sport_entries.count >= self.grade.entry_limit
      SportEntryMailer.restricted_sport_withdrawal(self).deliver_now

      if self.grade.sport_entries.count > self.grade.entry_limit
        SportEntryMailer.restricted_sport_offer(self).deliver_now 
        self.grade.set_waiting_list_expiry! 
      end
    end
  end

  def check_sport_draw_withdrawal_emails
    # Send an email if a team has withdrawn from a sport section for which the draw is complete
    if self.status == "Entered" && 
      self.grade.status != "Open" &&
      self.section &&
      self.section.number_in_draw &&
      self.section.number_in_draw > 0
     SportEntryMailer.draw_entry_withdrawal(self).deliver_now
    end
  end

  def check_sport_draw_addition_emails
    # Send an email if a team has entered into a sport section for which the draw is complete
    if self.status == "Entered" && 
      self.grade.status != "Open" &&
      self.section &&
      self.section.number_in_draw &&
      self.section.number_in_draw > 0
     SportEntryMailer.draw_entry_addition(self).deliver_now
   end
 end

  def remove_participants_from_entry!
    participants.each do |participant|
      participant = Participant.find(participant.id)
      participant.sport_entries.destroy(self)
      participant.save
    end
  end

  def check_waiting_list
    self.grade.check_waiting_list_status!
  end

  def self.sync_fields
    ['section_id',
      'team_number',
      'group_number', 
      'group_id',
      'status',
      'grade_id'
    ]
  end
end
