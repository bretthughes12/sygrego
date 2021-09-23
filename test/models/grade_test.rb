# == Schema Information
#
# Table name: grades
#
#  id                      :bigint           not null, primary key
#  active                  :boolean
#  database_rowid          :integer
#  entries_to_be_allocated :integer          default(999)
#  entry_limit             :integer
#  gender_type             :string(10)       default("Open"), not null
#  grade_type              :string(10)       default("Team"), not null
#  max_age                 :integer          default(29), not null
#  max_participants        :integer          default(0), not null
#  min_age                 :integer          default(11), not null
#  min_females             :integer          default(0), not null
#  min_males               :integer          default(0), not null
#  min_participants        :integer          default(0), not null
#  name                    :string(50)       not null
#  one_entry_per_group     :boolean
#  over_limit              :boolean
#  starting_entry_limit    :integer
#  status                  :string(20)       default("Open"), not null
#  team_size               :integer          default(1)
#  updated_by              :bigint
#  waitlist_expires_at     :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  sport_id                :integer          default(0), not null
#
# Foreign Keys
#
#  fk_rails_...  (sport_id => sports.id)
#
require "test_helper"

class GradeTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def setup
    @user = FactoryBot.create(:user)
    @grade = FactoryBot.create(:grade, name: "Order1")
  end

  test "should compare sport grades" do
    #comparison against self
    assert_equal 0, @grade <=> @grade 
    #different name
    other_grade = FactoryBot.create(:grade, name: "Order2")
    assert_equal -1, @grade <=> other_grade
  end

  test "should inherit sport name from sport" do
    assert_equal @grade.sport.name, @grade.sport_name
  end

  test "should use individual limit for max entries for singles" do
    singles = FactoryBot.create(:grade, grade_type: "Singles")

    assert_equal singles.sport.max_indiv_entries_group, singles.max_entries_group
  end
    
  test "should use individual limit for max entries for doubles" do
    doubles = FactoryBot.create(:grade, grade_type: "Doubles")
    
    assert_equal doubles.sport.max_indiv_entries_group, doubles.max_entries_group
  end
    
  test "should use team limit for max entries for teams" do
    team = FactoryBot.create(:grade, grade_type: "Team")
    
    assert_equal team.sport.max_team_entries_group, team.max_entries_group
  end
    
  test "should default to zero limit for max entries for invalid" do
    invalid = FactoryBot.build(:grade, grade_type: "Invalid")
    invalid.save(validate: false)
    
    assert_equal 0, invalid.max_entries_group
  end
    
  test "should close a sport grade" do
    @grade.close!

    @grade.reload
    assert_equal "Closed", @grade.status
  end

  test "should import grades from file" do
    FactoryBot.create(:sport, name: "Hockey")
    file = fixture_file_upload('grade.csv','application/csv')
    
    assert_difference('Grade.count') do
      @result = Grade.import(file, @user)
    end

    assert_equal 1, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 0, @result[:errors]
  end

  test "should update exiting grades from file" do
    sport = FactoryBot.create(:sport, name: "Hockey")
    grade = FactoryBot.create(:grade, sport: sport, name: 'Hockey Open B', status: "Open")
    file = fixture_file_upload('grade.csv','application/csv')
    
    assert_no_difference('Grade.count') do
      @result = Grade.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 1, @result[:updates]
    assert_equal 0, @result[:errors]

    grade.reload
    assert_equal "Closed", grade.status
  end

  test "should not import grades with errors from file" do
    FactoryBot.create(:sport, name: "Hockey")
    file = fixture_file_upload('invalid_grade.csv','application/csv')
    
    assert_no_difference('Grade.count') do
      @result = Grade.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]
  end

  test "should not update grades with errors from file" do
    sport = FactoryBot.create(:sport, name: "Hockey")
    grade = FactoryBot.create(:grade, sport: sport, name: 'Hockey Open B')
    file = fixture_file_upload('invalid_grade.csv','application/csv')
    
    assert_no_difference('Grade.count') do
      @result = Grade.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]

    grade.reload
    assert_not_equal 200, grade.max_age
  end
end
