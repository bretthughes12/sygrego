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
      result = RoundRobinMatch.where(draw_number: fields[0].to_i).first
      if result
        result.court = fields[3]
        result.complete = fields[5]
        result.entry_a_id = fields[6]
        result.score_a = fields[9]
        result.entry_b_id = fields[10]
        result.score_b = fields[13]
        result.forfeit_a = fields[14]
        result.forfeit_b = fields[15]
        result.entry_umpire_id = fields[16]
        result.forfeit_umpire = fields[18]
        result.updated_by = user.id

        if result.save
          updates += 1
        else
          errors += 1
          error_list << result
        end
      else
        result = RoundRobinMatch.create(
          draw_number:          fields[0],
          section_id:           fields[1],
          court:                fields[3],
          match:                fields[4].to_i,
          complete:             fields[5].to_i,
          entry_a_id:           fields[6],
          score_a:              fields[9],
          entry_b_id:           fields[10],
          score_b:              fields[13],
          forfeit_a:            fields[14],
          forfeit_b:            fields[15],
          entry_umpire_id:      fields[16],
          forfeit_umpire:       fields[18],
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

  def sync_create_action
    if match < 100
      nil
    else
      'CREATE'
    end
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
