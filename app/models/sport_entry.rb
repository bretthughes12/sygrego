# == Schema Information
#
# Table name: sport_entries
#
#  id              :bigint           not null, primary key
#  chance_of_entry :integer          default(100)
#  multiple_teams  :boolean          default(FALSE)
#  status          :string(20)       default("Requested")
#  team_number     :integer          default(1), not null
#  updated_by      :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  captaincy_id    :bigint
#  grade_id        :bigint           not null
#  group_id        :bigint           not null
#  section_id      :bigint
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
  belongs_to :section
  belongs_to :captaincy, class_name: 'Participant'
  has_many   :participants, through: :participants_sport_entries

  scope :entered, -> { where(status: 'Entered') }
  scope :requested, -> { where(status: 'Requested') }
  scope :entered_or_requested, -> { where("status in ('Entered', 'Requested')") }
  scope :waiting_list, -> { where(status: 'Waiting List') }
  scope :to_be_confirmed, -> { where(status: 'To Be Confirmed') }

  delegate :draw, to: :section
  delegate :grade_type,
           :sport,
           :session,
#           :eligible_to_participate?,
#           :sport_preferences,
           :team_size, to: :grade

#  before_validation :validate_number_of_entries_in_sport, on: :create

  STATUSES = ['Requested',
    'To Be Confirmed',
    'Entered',
    'Waiting List'].freeze

  validates :status, 
    presence: true,
    length: { maximum: 20 },
    inclusion: { in: STATUSES }
  validates :sport_grade_id,         
    presence: true
  validates :group_id,               
    presence: true
  validates :team_number,            
    presence: true,
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

  def sport_id
    cached_grade.nil? ? 0 : cached_grade.sport.id
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

  def number_of_participants
    @number_of_participants ||= cached_participants.count
  end

#  def section_name
#    section.nil? ? cached_grade.name : section.name
#  end

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

  def entry_can_be_deleted(settings)
    !draw_complete(settings) ||
      cached_grade.status == 'Open' ||
      status == 'Waiting List'
  end

#  def available_sport_preferences
#    sport_preferences.reject do |p|
#      p.preference.nil? ||
#        participants.include?(p.participant) ||
#        p.group != group ||
#        !p.participant.coming ||
#        p.participant.spectator ||
#        !p.participant.can_play_grade(cached_grade)
#    end
#  end

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
  end

  def reject!
    self.status = 'Waiting List'
    save
    group.increment_allocation_bonus!
  end

#  def allocation_factor
#    @ac ||= AllocationCalculation.new(self)
#    @ac.allocation_factor
#  end

#  def allocation_chance
#    @ac ||= AllocationCalculation.new(self)
#    limit = cached_sport_grade.entries_to_be_allocated

#    if status == 'Entered'
#      100

      # already missed out
#    elsif status == 'Missed Out'
#      0

      # all entries for this grade have been allocated
#    elsif limit < 1
#      0

      # the grade has not reached its limit yet
#    elsif cached_sport_grade.sport_entries.requested.count <= limit
#      100

      # there are enough spots to be allocated for each group to have one (groups
      # wanting more than one go into a ballot)
#    elsif @ac.number_of_groups_in_sport_grade < limit
#      if high_priority
#        100
#      else
#        @ac.high_priority = false
#        @ac.allocation_chance
#      end

      # there are exactly enough spots to be allocated for each group to have one,
      # so all second (and third, etc) entries automatically miss out
#    elsif @ac.number_of_groups_in_sport_grade == limit
#      if high_priority
#        100
#      else
#        0
#      end

      # there are not enough spots for one for each church, so all second (and third, etc)
      # entries automatically miss out and first entries go into the ballot
#    else
#      if high_priority
#        @ac.high_priority = true
#        @ac.allocation_chance
#      else
#        0
#      end
#    end
#  end

private

#  def validate_number_of_entries_in_sport
#    if cached_grade && cached_grade.sport.group_entries(group) >= cached_grade.sport.max_entries_group
#      errors.add(:grade_id, 'too many entries in this sport')
#    end
#  end

  def validate_if_entry_can_be_deleted
    unless entry_can_be_deleted
      errors.add(:base, 'Sport grade is closed - deletion is not allowed')
    end
  end

  def draw_complete(settings)
    if cached_sport_grade.sport.classification == 'Team'
      settings.team_draws_complete
    else
      settings.indiv_draws_complete
    end
  end
end