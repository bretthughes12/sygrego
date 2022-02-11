# == Schema Information
#
# Table name: statistics
#
#  id                            :bigint           not null, primary key
#  number_of_groups              :integer
#  number_of_participants        :integer
#  number_of_sport_entries       :integer
#  number_of_volunteer_vacancies :integer
#  weeks_to_syg                  :integer
#  year                          :integer          default(2022)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#

FactoryBot.define do
  factory :statistic do
    number_of_groups { 1 }
    number_of_participants { 1 }
    number_of_sport_entries { 1 }
    number_of_volunteer_vacancies { 1 }
    weeks_to_syg { 1 }
    year { 2020 }
  end
end
