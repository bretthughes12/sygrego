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

  scope :finals, -> { where('match > 99') }
  scope :semis, -> { where('match > 99 AND match < 200') }
  scope :gf, -> { where(match: 200) }
  scope :fixture, -> { where('match < 100') }
  
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
      group = fields[21].to_i
      section_id = fields[1].to_i

      entry_a = SportEntry.where(id: fields[6].to_i).first
      if entry_a && entry_a.group_number != group
        entry_a.group_number = group
        entry_a.save(validate: false)
      end

      entry_b = SportEntry.where(id: fields[10].to_i).first
      if entry_b && entry_b.group_number != group
        entry_b.group_number = group
        entry_b.save(validate: false)
      end

      section = Section.where(id: section_id).first
      if section
        section.finals_format = fields[26]
        section.number_of_groups = fields[23].to_i
        section.start_court = fields[27].to_i
        section.save(validate: false)
      end

      if result
        result.court = fields[3].to_i
        result.complete = fields[5]
        result.entry_a_id = fields[6].to_i
        result.score_a = fields[9].to_i
        result.entry_b_id = fields[10].to_i
        result.score_b = fields[13].to_i
        result.forfeit_a = fields[14]
        result.forfeit_b = fields[15]
        result.entry_umpire_id = fields[16].to_i
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
          draw_number:          fields[0].to_i,
          section_id:           fields[1].to_i,
          court:                fields[3].to_i,
          match:                fields[4].to_i,
          complete:             fields[5],
          entry_a_id:           fields[6].to_i,
          score_a:              fields[9].to_i,
          entry_b_id:           fields[10].to_i,
          score_b:              fields[13].to_i,
          forfeit_a:            fields[14],
          forfeit_b:            fields[15],
          entry_umpire_id:      fields[16].to_i,
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

  def self.import_excel(file, user)
    creates = 0
    updates = 0
    errors = 0
    error_list = []

    xlsx = Roo::Spreadsheet.open(file)

    xlsx.sheet(xlsx.default_sheet).parse(headers: true).each do |row|
      unless row['nDraw'] == 'nDraw'

        result = RoundRobinMatch.where(draw_number: row['nDraw'].to_i).first
        group = row['SYG Sport Entries_1_nGroup'].to_i
        section_id = row['idSection'].to_i

        entry_a = SportEntry.where(id: row['idWebA'].to_i).first
        if entry_a && entry_a.group_number != group
          entry_a.group_number = group
          entry_a.save(validate: false)
        end

        entry_b = SportEntry.where(id: row['idWebB'].to_i).first
        if entry_b && entry_b.group_number != group
          entry_b.group_number = group
          entry_b.save(validate: false)
        end

        section = Section.where(id: section_id).first
        if section
          section.finals_format = row['cFinalsFormat']
          section.number_of_groups = row['nGroups'].to_i
          section.start_court = row['nStartCourt'].to_i
          section.save(validate: false)
        end

        if result
          result.court = row['nCourt'].to_i
          result.complete = row['bComplete']
          result.entry_a_id = row['idWebA'].to_i
          result.score_a = row['nScoreA'].to_i
          result.entry_b_id = row['idWebB'].to_i
          result.score_b = row['nScoreB'].to_i
          result.forfeit_a = row['bForfeitA']
          result.forfeit_b = row['bForfeitB']
          result.entry_umpire_id = row['idWebUmp'].to_i
          result.forfeit_umpire = row['bForfeitUmpire']
          result.updated_by = user.id

          if result.save
            updates += 1
          else
            errors += 1
            error_list << result
          end
        else
          result = RoundRobinMatch.create(
            draw_number:          row['nDraw'].to_i,
            section_id:           row['idSection'].to_i,
            court:                row['nCourt'].to_i,
            match:                row['nMatch'].to_i,
            complete:             row['bComplete'],
            entry_a_id:           row['idWebA'].to_i,
            score_a:              row['nScoreA'].to_i,
            entry_b_id:           row['idWebB'].to_i,
            score_b:              row['nScoreB'].to_i,
            forfeit_a:            row['bForfeitA'],
            forfeit_b:            row['bForfeitB'],
            entry_umpire_id:      row['idWebUmp'].to_i,
            forfeit_umpire:       row['bForfeitUmpire'],
            updated_by:           user.id)

          if result.errors.empty?
            creates += 1
          else    
            errors += 1
            error_list << result
          end
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
  
  def self.sync_row
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
