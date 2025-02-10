# == Schema Information
#
# Table name: ballot_results
#
#  id                     :bigint           not null, primary key
#  entry_limit            :integer
#  factor                 :integer
#  grade_name             :string(50)       not null
#  group_name             :string(50)       not null
#  new_group              :boolean
#  one_entry_per_group    :boolean
#  over_limit             :boolean
#  preferred_section_name :string(50)
#  section_name           :string(50)
#  sport_entry_name       :string
#  sport_entry_status     :string(20)       not null
#  sport_name             :string(20)       not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require "test_helper"

class BallotResultTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
