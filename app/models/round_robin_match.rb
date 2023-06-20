# == Schema Information
#
# Table name: round_robin_matches
#
#  id              :bigint           not null, primary key
#  complete        :boolean          default(FALSE)
#  court           :integer          default(1)
#  draw_number     :bigint
#  forfeit_a       :boolean          default(FALSE)
#  forfeit_b       :boolean          default(FALSE)
#  forfeit_umpire  :boolean          default(FALSE)
#  match           :integer
#  score_a         :integer          default(0)
#  score_b         :integer          default(0)
#  updated_by      :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  entry_a_id      :bigint
#  entry_b_id      :bigint
#  entry_umpire_id :bigint
#  section_id      :bigint
#
# Indexes
#
#  index_round_robin_matches_on_draw_number      (draw_number)
#  index_round_robin_matches_on_entry_a_id       (entry_a_id)
#  index_round_robin_matches_on_entry_b_id       (entry_b_id)
#  index_round_robin_matches_on_entry_umpire_id  (entry_umpire_id)
#  index_round_robin_matches_on_section_id       (section_id)
#
class RoundRobinMatch < ApplicationRecord
  include Auditable

  belongs_to :section
  belongs_to :entry_a, class_name: "SportEntry", optional: true
  belongs_to :entry_b, class_name: "SportEntry", optional: true
  belongs_to :entry_umpire, class_name: "SportEntry", optional: true

  validates :court,         numericality: { only_integer: true }
  validates :match,         numericality: { only_integer: true }
  validates :score_a,       numericality: { only_integer: true }
  validates :score_b,       numericality: { only_integer: true }

  def entry_a_team_text
    entry_a.nil? ? '' : entry_a.group.abbr + ' ' + entry_a.team_number.to_s
  end

  def entry_b_team_text
    entry_b.nil? ? '' : entry_b.group.abbr + ' ' + entry_b.team_number.to_s
  end

  def import_score_a
    forfeit_a? ? -1 : score_a
  end

  def import_score_b
    forfeit_b? ? -1 : score_b
  end

  def self.import(file, user)
    creates = 0
    updates = 0
    errors = 0
    error_list = []

    CSV.foreach(file.path, headers: true) do |fields|
      result = SportResultEntry.where(section_id: fields[0].to_i, match: fields[3].to_i).first
      if result
        result.court = fields[2]
        result.complete = fields[4]
        result.entry_a_id = fields[5]
        result.team_a = fields[7]
        result.score_a = fields[8]
        result.entry_b_id = fields[9]
        result.team_b = fields[11]
        result.score_b = fields[12]
        result.forfeit_a = fields[13]
        result.forfeit_b = fields[14]
        result.entry_umpire_id = fields[15]
        result.forfeit_umpire = fields[17]
        result.blowout_rule = fields[18]
        result.forfeit_score = fields[19]
        result.group = fields[20]
        result.groups = fields[22]
        result.finals_format = fields[25]
        result.start_court = fields[26]
        result.updated_by = user.id

        if result.save
          updates += 1
        else
          errors += 1
          error_list << result
        end
      else
        result = SportResultEntry.create(
          section_id:           fields[0],
          court:                fields[2],
          match:                fields[3].to_i,
          complete:             fields[4].to_i,
          entry_a_id:           fields[5],
          team_a:               fields[7],
          score_a:              fields[8],
          entry_b_id:           fields[9],
          team_b:               fields[11],
          score_b:              fields[12],
          forfeit_a:            fields[13],
          forfeit_b:            fields[14],
          entry_umpire_id:      fields[15],
          forfeit_umpire:       fields[17],
          blowout_rule:         fields[18],
          forfeit_score:        fields[19],
          group:                fields[20],
          groups:               fields[22],
          finals_format:        fields[25],
          start_court:          fields[26],
          updated_by:           user.id)

        if result.errors.empty?
          creates += 1
        else    
          errors += 1
          error_list << result
        end
      end
    end

    { creates: creates, updates: updates, errors: errors, error_list: error_list }
  end

  private
  
  def self.sync_fields
    [
      'court',
      'match',
      'complete',
      'entry_a_id',
      'score_a',
      'entry_b_id',
      'score_b',
      'forfeit_a',
      'forfeit_b',
      'entry_umpire_id',
      'forfeit_umpire',
      'section_id'
    ]
  end
end
