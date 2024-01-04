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
#  one_entry_per_group     :boolean          default(FALSE)
#  over_limit              :boolean          default(FALSE)
#  starting_entry_limit    :integer
#  status                  :string(20)       default("Open"), not null
#  team_size               :integer          default(1)
#  updated_by              :bigint
#  waitlist_expires_at     :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  sport_id                :bigint           default(0), not null
#
# Indexes
#
#  index_grades_on_name  (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (sport_id => sports.id)
#

require "test_helper"

class GradeTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @setting = FactoryBot.create(:setting)
    @grade = FactoryBot.create(:grade, name: "Order1")
    @group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: @group)
  end

  test "should compare sport grades" do
    #comparison against self
    assert_equal 0, @grade <=> @grade 
    #different name
    other_grade = FactoryBot.create(:grade, name: "Order2")
    assert_equal -1, @grade <=> other_grade
  end

  test "should show non-final venue name for multiple possible venues" do
    #grade has a couple of possible venues
    FactoryBot.create(:section, grade: @grade)
    FactoryBot.create(:section, grade: @grade)
    
    assert_equal 'Multiple venues available', @grade.venue_name
  end

  test "should show venue name and id for single venues" do
    #grade has only one possibility
    grade_with_one_venue = FactoryBot.create(:grade)
    section = FactoryBot.create(:section, grade: grade_with_one_venue)
    FactoryBot.create(:section, grade: grade_with_one_venue,
                                venue: section.venue)
    
    assert_equal section.venue.name, grade_with_one_venue.venue_name
    assert_equal section.venue.id, grade_with_one_venue.venue_id
  end

  test "should show non-final venue name for grade with no sections" do
    #grade has no sections
    grade_with_no_sections = FactoryBot.create(:grade)

    assert_equal 'Multiple venues available', grade_with_no_sections.venue_name
  end
  
  test "should have multiple possible venues" do
    #grade has a couple of possible venues
    FactoryBot.create(:section, grade: @grade)
    FactoryBot.create(:section, grade: @grade)
    
    assert @grade.possible_venues.size > 1
  end
  
  test "should have one possible venue for same venue" do
    #grade has only one possibility
    grade_with_one_venue = FactoryBot.create(:grade)
    section = FactoryBot.create(:section, grade: grade_with_one_venue)
    FactoryBot.create(:section, grade: grade_with_one_venue,
                                venue: section.venue)

    assert_equal 1, grade_with_one_venue.possible_venues.size
  end
  
  test "should have no possible venues for grade with no sections" do
    #grade has no sections
    grade_with_no_sections = FactoryBot.create(:grade)

    assert_equal 0, grade_with_no_sections.possible_venues.size
  end
  
  test "should have multiple possible sessions" do
    #grade has a couple of possible venues
    FactoryBot.create(:section, grade: @grade)
    FactoryBot.create(:section, grade: @grade)
    
    assert @grade.possible_sessions.size > 1
    assert_equal 'Multiple sessions available', @grade.session_name
  end
  
  test "should have one possible session for same session" do
    #grade has only one possibility
    grade_with_one_session = FactoryBot.create(:grade)
    section = FactoryBot.create(:section, grade: grade_with_one_session)
    FactoryBot.create(:section, grade: grade_with_one_session,
                                session: section.session)

    assert_equal 1, grade_with_one_session.possible_sessions.size
    assert_equal section.session_name, grade_with_one_session.session_name
  end
  
  test "should have no possible sessions for grade with no sections" do
    #grade has no sections
    grade_with_no_sections = FactoryBot.create(:grade)

    assert_equal 0, grade_with_no_sections.possible_sessions.size
    assert_equal 'Multiple sessions available', grade_with_no_sections.session_name
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
    
  def test_grade_entries_entered
    #"Entered"
    entered = FactoryBot.create(:sport_entry, grade: @grade, status: "Entered")

    assert @grade.entries_entered.include?(entered)

    #not "Entered"
    other_grade = FactoryBot.create(:grade)
    not_entered = FactoryBot.create(:sport_entry, grade: other_grade, status: "Entered")
    
    assert !@grade.entries_entered.include?(not_entered)
    
    #nil list
    grade_with_no_entries = FactoryBot.create(:grade)

    assert grade_with_no_entries.entries_entered.empty?
  end

  def test_grade_entries_requested
    #"Requested"
    requested = FactoryBot.create(:sport_entry, grade: @grade, status: "Requested")

    assert @grade.entries_requested.include?(requested)
    
    #not "Requested"
    other_grade = FactoryBot.create(:grade)
    not_requested = FactoryBot.create(:sport_entry, grade: other_grade, status: "Requested")
    
    assert !@grade.entries_requested.include?(not_requested)
    
    #nil list
    grade_with_no_entries = FactoryBot.create(:grade)

    assert grade_with_no_entries.entries_requested.empty?
  end

  def test_grade_entries_waiting
    #"Waiting List"
    missed_out = FactoryBot.create(:sport_entry, grade: @grade, status: "Waiting List")

    assert @grade.entries_waiting.include?(missed_out)
    
    #not "Waiting List"
    other_grade = FactoryBot.create(:grade)
    not_missed_out = FactoryBot.create(:sport_entry, grade: other_grade, status: "Waiting List")
    
    assert !@grade.entries_waiting.include?(not_missed_out)
    
    #nil list
    grade_with_no_entries = FactoryBot.create(:grade)

    assert grade_with_no_entries.entries_waiting.empty?
  end

  def test_grade_entries_to_be_confirmed
    #"Waiting List"
    missed_out = FactoryBot.create(:sport_entry, grade: @grade, status: "To Be Confirmed")

    assert @grade.entries_to_be_confirmed.include?(missed_out)
    
    #not "Waiting List"
    other_grade = FactoryBot.create(:grade)
    not_missed_out = FactoryBot.create(:sport_entry, grade: other_grade, status: "To Be Confirmed")
    
    assert !@grade.entries_to_be_confirmed.include?(not_missed_out)
    
    #nil list
    grade_with_no_entries = FactoryBot.create(:grade)

    assert grade_with_no_entries.entries_to_be_confirmed.empty?
  end

  def test_sport_grade_starting_status
    #No entry limit
    grade = FactoryBot.create(:grade, entry_limit: nil, status: "Open")

    assert_equal "Entered", grade.starting_status
    
    #Entry limit, but grade is still open
    grade = FactoryBot.create(:grade, entry_limit: 8, status: "Open")
    
    assert_equal "Requested", grade.starting_status
    
    #Entry limit, filled and grade is closed
    grade = FactoryBot.create(:grade, entry_limit: 8, status: "Closed")
    8.times do
      FactoryBot.create(:sport_entry, grade: grade)
    end
    
    assert_equal "Waiting List", grade.starting_status
  end

  def test_sport_grade_starting_sport_section
    #Grade with only one section
    section = FactoryBot.create(:section, grade: @grade)
    assert_equal section, @grade.starting_section
    
    #Section(s) are all full
    full_grade = FactoryBot.create(:grade)
    section1 = FactoryBot.create(:section, grade: full_grade, number_in_draw: 4)
    section2 = FactoryBot.create(:section, grade: full_grade, number_in_draw: 4)
    4.times do
      FactoryBot.create(:sport_entry, grade: full_grade, section: section1)
      FactoryBot.create(:sport_entry, grade: full_grade, section: section2)
    end
    
    assert_nil full_grade.starting_section
    
    #Multiple sections - first is full, but second has space
    not_quite_full_grade = FactoryBot.create(:grade)
    section1 = FactoryBot.create(:section, grade: not_quite_full_grade, number_in_draw: 4)
    section2 = FactoryBot.create(:section, grade: not_quite_full_grade, number_in_draw: 4)
    4.times do
      FactoryBot.create(:sport_entry, grade: not_quite_full_grade, section: section1)
    end
    3.times do
      FactoryBot.create(:sport_entry, grade: not_quite_full_grade, section: section2)
    end

    assert_equal section2, not_quite_full_grade.starting_section
    
    #Multiple sections - none have 'number_in_draw' filled out
    grade_with_sections = FactoryBot.create(:grade)
    section1 = FactoryBot.create(:section, grade: grade_with_sections, number_in_draw: nil)
    section2 = FactoryBot.create(:section, grade: grade_with_sections, number_in_draw: nil)

    assert_nil grade_with_sections.starting_section
  end
  
  test "participant should not be eligible to participate if they are too young" do
    grade = FactoryBot.create(:grade, min_age: 18)
    participant = FactoryBot.create(:participant, :under18, group: @group)
    
    assert !grade.eligible_to_participate?(participant)
  end
  
  test "participant should be eligible to participate if they are old enough" do
    grade = FactoryBot.create(:grade, min_age: 18)
    participant = FactoryBot.create(:participant, age: 18, group: @group)
    
    assert grade.eligible_to_participate?(participant)
  end
  
  test "participant should not be eligible to participate if they are too old" do
    grade = FactoryBot.create(:grade, max_age: 17)
    participant = FactoryBot.create(:participant, age: 18, group: @group)
    
    assert !grade.eligible_to_participate?(participant)
  end
  
  test "participant should be eligible to participate if they are young enough" do
    grade = FactoryBot.create(:grade, max_age: 17)
    participant = FactoryBot.create(:participant, :under18, group: @group)
    
    assert grade.eligible_to_participate?(participant)
  end
  
  test "either sex should be eligible to participate in open grades" do
    grade = FactoryBot.create(:grade, gender_type: "Open")
    male = FactoryBot.create(:participant, gender: "M", group: @group)
    female = FactoryBot.create(:participant, gender: "F", group: @group)
    
    assert grade.eligible_to_participate?(male)
    assert grade.eligible_to_participate?(female)
  end
  
  test "either sex should be eligible to participate in mixed grades" do
    grade = FactoryBot.create(:grade, gender_type: "Mixed")
    male = FactoryBot.create(:participant, gender: "M", group: @group)
    female = FactoryBot.create(:participant, gender: "F", group: @group)
    
    assert grade.eligible_to_participate?(male)
    assert grade.eligible_to_participate?(female)
  end
  
  test "females should be eligible to participate in ladies grades" do
    grade = FactoryBot.create(:grade, gender_type: "Ladies")
    female = FactoryBot.create(:participant, gender: "F", group: @group)
    
    assert grade.eligible_to_participate?(female)
  end
  
  test "males should not be eligible to participate in ladies grades" do
    grade = FactoryBot.create(:grade, gender_type: "Ladies")
    male = FactoryBot.create(:participant, gender: "M", group: @group)
    
    assert !grade.eligible_to_participate?(male)
  end
  
  test "males should be eligible to participate in mens grades" do
    grade = FactoryBot.create(:grade, gender_type: "Mens")
    male = FactoryBot.create(:participant, gender: "M", group: @group)
    
    assert grade.eligible_to_participate?(male)
  end
  
  test "females should not be eligible to participate in mens grades" do
    grade = FactoryBot.create(:grade, gender_type: "Mens")
    female = FactoryBot.create(:participant, gender: "F", group: @group)
    
    assert !grade.eligible_to_participate?(female)
  end

  test "should close a sport grade" do
    @grade.close!

    @grade.reload
    assert_equal "Closed", @grade.status
  end

  test "should collect volunteers from sections" do
    section = FactoryBot.create(:section, grade: @grade)
    volunteer = FactoryBot.create(:volunteer)
    volunteer.sections << section

    @grade.reload
    assert_equal 1, @grade.volunteers.size
    assert_equal volunteer, @grade.volunteers.first
  end

  test "should collect sport coordinators" do
    section = FactoryBot.create(:section, grade: @grade)
    participant = FactoryBot.create(:participant, group: @group)
    vt = FactoryBot.create(:volunteer_type, :sport_coord)
    volunteer = FactoryBot.create(:volunteer, 
      volunteer_type: vt,
      participant: participant)
    volunteer.sections << section

    @grade.reload
    assert_equal 1, @grade.coordinators_groups.size
    assert_equal participant.group, @grade.coordinators_groups.first
  end

  test "should set the waiting list expiry" do
    @grade.set_waiting_list_expiry!

    @grade.reload
    assert_not_nil @grade.waitlist_expires_at
  end

  test "should reset the waiting list expiry" do
    grade = FactoryBot.create(:grade, waitlist_expires_at: Time.now + 2.days)

    grade.check_waiting_list_status!

    grade.reload
    assert_nil grade.waitlist_expires_at
  end

  test "should calculate number of courts from sections" do
    FactoryBot.create(:section, grade: @grade, number_of_courts: 2)

    @grade.reload
    assert_equal 2, @grade.total_courts_available
  end

  test "should default number of courts with no sections" do
    assert_equal 0, @grade.total_courts_available
  end

  test "should calculate teams per court from sections" do
    grade = FactoryBot.create(:grade, entry_limit: 10)

    FactoryBot.create(:section, grade: grade, number_of_courts: 2)

    @grade.reload
    assert_equal 5, grade.teams_per_court
  end

  test "should default teams per court with no sections" do
    grade = FactoryBot.create(:grade, entry_limit: 10)

    assert_equal 0, grade.teams_per_court
  end

  test "should default teams per court with no limit" do
    grade = FactoryBot.create(:grade, entry_limit: nil)

    assert_equal 999, grade.teams_per_court
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
