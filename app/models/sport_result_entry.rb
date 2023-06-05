class SportResultEntry < ApplicationRecord
  include Auditable

  belongs_to :section

  private
  
  def self.sync_fields
    [
      'court',
      'match',
      'complete',
      'entry_a',
      'team_a',
      'score_a',
      'entry_b',
      'team_b',
      'score_b',
      'forfeit_a',
      'forfeit_b',
      'entry_umpire',
      'forfeit_umpire',
      'blowout_rule',
      'forfeit_score',
      'groups',
      'finals_format',
      'start_court',
      'section'
    ]
  end
end
