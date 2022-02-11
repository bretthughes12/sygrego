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

require "test_helper"

class StatisticTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
