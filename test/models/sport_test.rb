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
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
require "test_helper"

class SportTest < ActiveSupport::TestCase
  test "should have 15 per page" do
    assert_equal 15, Sport.per_page
  end

  test "should calculate total entries from indiv and team" do
    sport = FactoryBot.create(:sport,
                              max_indiv_entries_group: 10,
                              max_team_entries_group: 10)

    assert_equal 20, sport.max_entries_group
  end

  test "should use name to sort sports" do
    sport1 = FactoryBot.create(:sport, name: "A")
    sport2 = FactoryBot.create(:sport, name: "B")

    assert_equal true, sport1 < sport2
  end
end
