# == Schema Information
#
# Table name: sport_preferences
#
#  id             :bigint           not null, primary key
#  preference     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  grade_id       :bigint           not null
#  participant_id :bigint           not null
#
# Indexes
#
#  index_sport_preferences_on_grade_id        (grade_id)
#  index_sport_preferences_on_participant_id  (participant_id)
#
# Foreign Keys
#
#  fk_rails_...  (grade_id => grades.id)
#  fk_rails_...  (participant_id => participants.id)
#
class SportPreference < ApplicationRecord
  belongs_to :grade
  belongs_to :participant

  scope :entered, -> { where('preference is not null') }

  delegate :sport, to: :grade

  validates :preference, 
    numericality: { only_integer: true },
    allow_blank: true

  def <=>(other)
    cached_grade.name <=> other.cached_grade.name
  end

  def self.locate_for_participant(participant)
    SportPreference
      .joins(:grade, :participant)
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

    prefs = []
    prefs = grades.collect do |g|
      SportPreference.find_or_create_by(participant_id: participant.id, grade_id: g.id) do |sp|
        sp.participant_id = participant.id
        sp.grade_id = g.id
      end
    end
    prefs
  end

  def self.prepare_for_group(group)
    grades = group.filtered_grades.sort

    prefs = []
    prefs = grades.collect do |g|
      SignupSportPreference.new(grade_id: g.id)
    end
    prefs
  end

  def self.store(participant_id, grade_id, preference)
    pref = SportPreference.find_by_participant_id_and_grade_id(participant_id, grade_id) || SportPreference.new(participant_id: participant_id, grade_id: grade_id)

    pref.preference = preference
    pref.save
  end

  def self.create_for_participant(participant, params)
    pp participant 
    params.each do |param|
      unless param[:preference] == ""
#        pp param
        pref = SportPreference.new(participant_id: participant.id, grade_id: param[:grade_id].to_i, preference: param[:preference].to_i) 
        if pref.save
          puts 'Created SP'
          pp pref
        else
          puts 'Save failed'
          pp pref
          pp pref.errors
        end
      end
    end
  end

  def self.locate_for_group(group, options = {})
    prefs = SportPreference
            .joins([:grade, { participant: :group }])
            .entered
            .where(participants: { group_id: group.id })
            .where(participants: { coming: true })
            .includes({ participant: %i[group sport_entries] }, grade: %i[sport sport_entries])
            .order('grades.name')
            .sort

    prefs = prefs.reject { |p| (options[:entered].nil? || !options[:entered]) && p.is_entered? }
    prefs = prefs.reject { |p| (options[:in_sport].nil? || !options[:in_sport]) && !p.is_entered? && p.is_entered_this_sport? }
  end

  def cached_participant
    @participant ||= participant
  end

  def cached_grade
    @grade ||= grade
  end

  def group
    @group ||= cached_participant.group
  end

  def sport_entry
    @sport_entry ||= cached_participant.first_entry_in_grade(cached_grade)
  end

  def available_sport_entry
    @available_sport_entry ||= group.first_entry_in_grade(cached_grade)
  end

  def is_entered?
    @is_entered ||= cached_participant.is_entered_in?(cached_grade)
  end

  def is_entered_this_sport?
    @is_entered_this_sport ||= cached_participant.is_entered_in_sport?(cached_grade.sport)
  end

  def is_sport_entry_available?
    @is_sport_entry_available ||= !available_sport_entry.nil?
  end

  def entry_comment(entry)
    if is_entered_this_sport?
      'Sport clash (not allowed)'
    elsif self.grade != entry.grade
      'Different grade'
    else
      ''
    end
  end
end
