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
  belongs_to :preferred_section, class_name: 'Section', optional: true
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
           :eligible_to_participate?,
           :sport_preferences,
           :team_size,
           :min_under_18s, to: :grade

  before_validation :validate_number_of_entries_in_sport, on: :create
  before_validation :validate_number_of_entries_in_grade, on: :create
  after_create :update_team_numbers
  after_create :update_grade_flags
  after_create :check_waiting_list
  after_create :check_sport_draw_addition_emails
  after_update :update_grade_flags, if: :saved_change_to_status?
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
    @participants ||= participants.order(:surname, :first_name)
  end

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
    preferred_section.nil? ? "" : preferred_section.name 
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

  def requires_under_18s?
    cached_participants.under_18s.count < cached_grade.min_under_18s
  end

  def can_take_participants?
    number_of_participants < cached_grade.max_participants
  end

  def issues
    issues = []
    issues << 'Not enough females' if requires_females?
    issues << 'Not enough males' if requires_males?
    issues << 'Not enough participants' if requires_participants?
    issues << 'Not enough under 18s' if requires_under_18s?
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
    elsif preferred_section  
      "Preferred: #{preferred_section.venue_name}"
    elsif cached_grade
      cached_grade.venue_name
      # else no action
    end
  end

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
    elsif preferred_section  
        "Preferred: #{preferred_section.session_name}"
    elsif cached_grade
      cached_grade.session_name
    # else no action (should not be possible)
    end
  end

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

  def available_sport_preferences
    sport.sport_preferences_for_group(group).reject do |p|
      p.preference.nil? ||
        participants.include?(p.participant) ||
        p.group != group ||
        !p.participant.coming ||
        !p.participant.can_play_grade(cached_grade) ||
        !cached_grade.eligible_to_participate?(p.participant)
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
    if preferred_section && preferred_section.can_take_more_entries?
      self.section = preferred_section
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

  def self.import_excel(file, user)
    creates = 0
    updates = 0
    errors = 0
    error_list = []

    xlsx = Roo::Spreadsheet.open(file)

    xlsx.sheet(xlsx.default_sheet).parse(headers: true).each do |row|
      unless row['Section'] == 'Section'

        group = Group.find_by_short_name(row['Group'].to_s)
        if group.nil?
          group = Group.find_by_short_name("No group")
        end

        grade = Grade.find_by_name(row['Grade'].to_s)
        grade_id = grade.id if grade
        section = Section.find_by_name(row['Section'].to_s)
        section_id = section.id if section
        preferred_section = Section.find_by_name(row['Preferred'].to_s)
        preferred_section_id = preferred_section.id if preferred_section

        if grade
          sport_entry = SportEntry.where(grade_id: grade.id, team_number: row['Team #'].to_i).first
        end

        if sport_entry
          sport_entry.section_id                = section_id
          sport_entry.preferred_section_id      = preferred_section_id
          sport_entry.group_id                  = group.id 
          sport_entry.status                    = row['Status']
          sport_entry.group_number              = row['Group #'].to_i

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
            status:                  row['Status'],
            team_number:             row['Team #'].to_i,
            group_number:            row['Group #'].to_i,
            updated_by:              user.id)

          if sport_entry.errors.empty?
              creates += 1
          else
              errors += 1
              error_list << sport_entry
          end
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

  def validate_number_of_entries_in_grade
    if cached_grade && cached_grade.sport.group_entries(group) >= cached_grade.max_entries_group
      errors.add(:grade_id, 'too many entries in this grade')
    end
  end

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
    participants.each do |p|
      participant = Participant.find(p.id)
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
      'group_id',
      'status',
      'grade_id'
    ]
  end
end
