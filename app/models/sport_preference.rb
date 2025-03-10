# == Schema Information
#
# Table name: sport_preferences
#
#  id             :bigint           not null, primary key
#  level          :string(100)
#  preference     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  grade_id       :bigint
#  participant_id :bigint           not null
#  sport_id       :bigint
#
# Indexes
#
#  index_sport_preferences_on_grade_id        (grade_id)
#  index_sport_preferences_on_participant_id  (participant_id)
#  index_sport_preferences_on_sport_id        (sport_id)
#
# Foreign Keys
#
#  fk_rails_...  (participant_id => participants.id)
#

class SportPreference < ApplicationRecord
  belongs_to :sport
  belongs_to :participant

  scope :entered, -> { where('preference is not null') }

  validates :preference, 
    numericality: { only_integer: true },
    allow_blank: true
  validates :sport_id, uniqueness: { scope: [:participant_id] }

  def <=>(other)
    cached_sport.name <=> other.cached_sport.name
  end

  def self.locate_for_participant(participant)
    SportPreference
      .joins(:sport, :participant)
      .entered
      .where(participant_id: participant.id)
      .sort
  end

  def self.prepare_for_participant(participant)
    grades = if participant
               (participant.available_grades +
                participant.group_grades_i_can_join +
                participant.grades)
                 .uniq
                 .sort &
                participant.group.filtered_grades
             else
               []
             end

    sports = grades.collect(&:sport).uniq.sort

    prefs = []
    prefs = sports.collect do |s|
      SportPreference.find_or_create_by(participant_id: participant.id, sport_id: s.id) do |sp|
        sp.participant_id = participant.id
        sp.sport_id = s.id
      end
    end
    prefs
  end

  def self.prepare_for_group(group)
    grades = group.filtered_grades.sort
    sports = grades.collect(&:sport).uniq.sort

    prefs = []
    prefs = sports.collect do |s|
      SignupSportPreference.new(sport_id: s.id)
    end
    prefs
  end

  def self.retain_from_signup(params)
    prefs = []
    prefs = params.collect do |p|
      SignupSportPreference.new(p)
    end
    prefs
  end

  def self.store(participant_id, sport_id, preference)
    pref = SportPreference.find_by_participant_id_and_sport_id(participant_id, sport_id) || SportPreference.new(participant_id: participant_id, sport_id: sport_id)

    pref.preference = preference
    pref.save
  end

  def self.create_for_participant(participant, params)
    params.each do |param|
      unless param[:preference] == ""
        pref = SportPreference.new(participant_id: participant.id, sport_id: param[:sport_id].to_i, preference: param[:preference].to_i) 
        pref.save
      end
    end
  end

  def self.locate_for_group(group, options = {})
    prefs = SportPreference
            .joins([:sport, { participant: :group }])
            .entered
            .where(participants: { group_id: group.id })
            .where(participants: { coming: true })
            .includes({ participant: %i[group sport_entries] }, :sport)
            .order('sports.name')
            .sort

    prefs = prefs.reject { |p| (options[:entered].nil? || !options[:entered]) && p.is_entered_this_sport? }
  end

  def cached_participant
    @participant ||= participant
  end

  def cached_sport
    @sport ||= sport
  end

  def group
    @group ||= cached_participant.group
  end

  def sport_entry
    @sport_entry ||= cached_participant.first_entry_in_sport(cached_sport)
  end

  def available_sport_entry
    @available_sport_entry ||= group.first_entry_in_sport(cached_sport)
  end

  def is_entered_this_sport?
    @is_entered_this_sport ||= cached_participant.is_entered_in_sport?(cached_sport)
  end

  def is_sport_entry_available?
    @is_sport_entry_available ||= !available_sport_entry.nil?
  end

  def entry_comment(entry)
    if is_entered_this_sport?
      'Sport clash (not allowed)'
    else
      ''
    end
  end
end
