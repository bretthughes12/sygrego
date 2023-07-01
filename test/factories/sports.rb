# == Schema Information
#
# Table name: sports
#
#  id                      :bigint           not null, primary key
#  active                  :boolean          default(TRUE)
#  allow_negative_score    :boolean          default(FALSE)
#  blowout_rule            :boolean          default(FALSE)
#  bonus_for_officials     :boolean          default(FALSE)
#  classification          :string(10)       not null
#  court_name              :string(20)       default("Court")
#  draw_type               :string(20)       not null
#  forfeit_score           :integer          default(0)
#  ladder_tie_break        :string(20)       default("Percentage")
#  max_entries_indiv       :integer          default(0), not null
#  max_indiv_entries_group :integer          default(0), not null
#  max_team_entries_group  :integer          default(0), not null
#  name                    :string(20)       not null
#  point_name              :string(20)       default("Point")
#  updated_by              :bigint
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_sports_on_name  (name) UNIQUE
#

FactoryBot.define do
    factory :sport do 
        sequence(:name)             { |n| "Sport#{n}"}
        active                      {true}
        classification              {"Team"}
        draw_type                   {"Open"}
        max_indiv_entries_group     {99}
        max_team_entries_group      {99}
        max_entries_indiv           {1}
    end
end    
