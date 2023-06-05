FactoryBot.define do
  factory :sport_result_entry do
    court { 1 }
    match { 1 }
    complete { false }
    entry_a { 1 }
    team_a { 1 }
    score_a { 1 }
    entry_b { 1 }
    team_b { 1 }
    score_b { 1 }
    forfeit_a { false }
    forfeit_b { false }
    entry_umpire { 1 }
    forfeit_umpire { false }
    blowout_rule { false }
    forfeit_score { 1 }
    groups { 1 }
    finals_format { "MyString" }
    start_court { 1 }
  end
end
