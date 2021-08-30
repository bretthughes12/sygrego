# == Schema Information
#
# Table name: sports
#
#  id                      :bigint           not null, primary key
#  active                  :boolean          default(TRUE)
#  bonus_for_officials     :boolean          default(FALSE)
#  classification          :string(10)       not null
#  court_name              :string(20)       default("Court")
#  draw_type               :string(20)       not null
#  lock_version            :integer          default(0)
#  max_entries_indiv       :integer          default(0), not null
#  max_indiv_entries_group :integer          default(0), not null
#  max_team_entries_group  :integer          default(0), not null
#  name                    :string(20)       not null
#  updated_by              :bigint
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
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
        lock_version                {1}
    end
end    
