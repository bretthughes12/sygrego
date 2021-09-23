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
#  max_entries_indiv       :integer          default(0), not null
#  max_indiv_entries_group :integer          default(0), not null
#  max_team_entries_group  :integer          default(0), not null
#  name                    :string(20)       not null
#  updated_by              :bigint
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
require "test_helper"

class SportTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def setup
    @user = FactoryBot.create(:user)
    @sport = FactoryBot.create(:sport)
  end

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

  test "should import sports from file" do
    file = fixture_file_upload('sport.csv','application/csv')
    
    assert_difference('Sport.count') do
      @result = Sport.import(file, @user)
    end

    assert_equal 1, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 0, @result[:errors]
  end

  test "should update exiting sports from file" do
    sport = FactoryBot.create(:sport, name: 'Hockey')
    file = fixture_file_upload('sport.csv','application/csv')
    
    assert_no_difference('Sport.count') do
      @result = Sport.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 1, @result[:updates]
    assert_equal 0, @result[:errors]

    sport.reload
    assert_equal "Field", sport.court_name
  end

  test "should not import sports with errors from file" do
    file = fixture_file_upload('invalid_sport.csv','application/csv')
    
    assert_no_difference('Sport.count') do
      @result = Sport.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]
  end

  test "should not update sports with errors from file" do
    sport = FactoryBot.create(:sport, name: 'Hockey')
    file = fixture_file_upload('invalid_sport.csv','application/csv')
    
    assert_no_difference('Sport.count') do
      @result = Sport.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]

    sport.reload
    assert_not_equal "Random", sport.court_name
  end

  test "should limit grades for a sport" do
    sport = FactoryBot.create(:sport)
    include_grade1 = FactoryBot.create(:grade, sport: sport)
    include_grade2 = FactoryBot.create(:grade, sport: sport)
    exclude_grade = FactoryBot.create(:grade, sport: sport)
    wrong_sport_grade = FactoryBot.create(:grade)

    sport.limit_grades_to([include_grade1, include_grade2, wrong_sport_grade])

    assert_equal 2, sport.grades_as_limited.size
    assert_equal true, sport.grades_as_limited.include?(include_grade1)
    assert_equal true, sport.grades_as_limited.include?(include_grade2)
    assert_equal false, sport.grades_as_limited.include?(wrong_sport_grade)
    assert_equal false, sport.grades_as_limited.include?(exclude_grade)
  end
end
