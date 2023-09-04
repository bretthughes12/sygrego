require "test_helper"

class AllocateRestrictedJobTest < ActiveJob::TestCase
  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @setting = FactoryBot.create(:setting)
  end

  test "restricted grades are allocated" do
    sport = FactoryBot.create(:sport, :team)
    grade = FactoryBot.create(:grade, :restricted, 
      sport: sport,
      entry_limit: 10)
    section1 = FactoryBot.create(:section, 
      grade: grade)
    section2 = FactoryBot.create(:section, 
      grade: grade)
    21.times do
      FactoryBot.create(:sport_entry, 
        grade: grade)
    end

    AllocateRestrictedJob.perform_now

    grade.reload
    section1.reload
    section2.reload
    assert_equal "Closed", grade.status
    assert_equal 10, grade.sport_entries.to_be_confirmed.count
    assert_equal 11, grade.sport_entries.waiting_list.count
    assert_equal 5, section1.sport_entries.count
    assert_equal 5, section2.sport_entries.count
  end

  test "groups with two teams are rejected" do
    sport = FactoryBot.create(:sport, :team)
    grade = FactoryBot.create(:grade, :restricted, 
      sport: sport,
      entry_limit: 10)
    section1 = FactoryBot.create(:section, 
      grade: grade)
    section2 = FactoryBot.create(:section, 
      grade: grade)
    9.times do
      FactoryBot.create(:sport_entry, 
        grade: grade)
    end
    entry1 = FactoryBot.create(:sport_entry, 
      grade: grade)
    entry2 = FactoryBot.create(:sport_entry, 
      grade: grade,
      group: entry1.group)

    AllocateRestrictedJob.perform_now

    grade.reload
    entry2.reload
    assert_equal "Closed", grade.status
    assert_equal 10, grade.sport_entries.to_be_confirmed.count
    assert_equal 1, grade.sport_entries.waiting_list.count
    assert_equal 'Waiting List', entry2.status
  end

  test "grades under limits are all entered" do
    sport = FactoryBot.create(:sport, :team)
    grade = FactoryBot.create(:grade, :restricted, 
      sport: sport,
      entry_limit: 10)
    section1 = FactoryBot.create(:section, 
      grade: grade)
    section2 = FactoryBot.create(:section, 
      grade: grade)
    9.times do
      FactoryBot.create(:sport_entry, 
        grade: grade)
    end

    AllocateRestrictedJob.perform_now

    grade.reload
    assert_equal "Closed", grade.status
    assert_equal 9, grade.sport_entries.entered.count
  end

  test "first teams of groups are allocated when fewer groups than limit" do
    sport = FactoryBot.create(:sport, :team)
    grade = FactoryBot.create(:grade, :restricted, 
      sport: sport,
      entry_limit: 10)
    section1 = FactoryBot.create(:section, 
      grade: grade)
    section2 = FactoryBot.create(:section, 
      grade: grade)
    7.times do
      FactoryBot.create(:sport_entry, 
        grade: grade)
    end
    entry1 = FactoryBot.create(:sport_entry, 
      grade: grade)
    entry2 = FactoryBot.create(:sport_entry, 
      grade: grade,
      group: entry1.group)
    entry3 = FactoryBot.create(:sport_entry, 
      grade: grade)
    entry4 = FactoryBot.create(:sport_entry, 
      grade: grade,
      group: entry3.group)
  
    AllocateRestrictedJob.perform_now

    grade.reload
    entry1.reload
    entry3.reload
    assert_equal "Closed", grade.status
    assert_equal 10, grade.sport_entries.to_be_confirmed.count
    assert_equal 1, grade.sport_entries.waiting_list.count
    assert_equal 'To Be Confirmed', entry1.status
    assert_equal 'To Be Confirmed', entry3.status
  end
end
