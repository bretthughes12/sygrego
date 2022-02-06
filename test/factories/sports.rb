# == Schema Information
#
# Table name: sports
#
#  id                      :integer          not null, primary key
#  name                    :string(20)       not null
#  classification          :string(10)       not null
#  active                  :boolean          default("true")
#  max_indiv_entries_group :integer          default("0"), not null
#  max_team_entries_group  :integer          default("0"), not null
#  max_entries_indiv       :integer          default("0"), not null
#  draw_type               :string(20)       not null
#  bonus_for_officials     :boolean          default("false")
#  court_name              :string(20)       default("Court")
#  updated_by              :integer
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
