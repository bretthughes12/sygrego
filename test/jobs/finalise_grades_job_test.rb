require "test_helper"

class FinaliseGradesJobTest < ActiveJob::TestCase
  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @setting = FactoryBot.create(:setting)
  end

  test "team grades are finalised" do
    sport = FactoryBot.create(:sport, :team)
    grade = FactoryBot.create(:grade, sport: sport, status: "Closed")
    session = FactoryBot.create(:session)
    venue = FactoryBot.create(:venue)
    section1 = FactoryBot.create(:section, 
      grade: grade, 
      venue: venue, 
      session: session)
    section2 = FactoryBot.create(:section, 
      grade: grade, 
      venue: venue, 
      session: session)
    16.times do
      FactoryBot.create(:sport_entry, 
        grade: grade,
        section: section1)
    end
    5.times do
      FactoryBot.create(:sport_entry, 
        grade: grade,
        section: section2)
    end

    FinaliseGradesJob.perform_now(:team)

    grade.reload
    section1.reload
    section2.reload
    assert_equal "Allocated", grade.status
    assert_equal 21, grade.entry_limit
    assert_equal 10, section1.number_in_draw
    assert_equal 11, section2.number_in_draw
    assert_equal 10, section1.sport_entries.count
    assert_equal 11, section2.sport_entries.count
  end

  test "individual grades are finalised" do
    sport = FactoryBot.create(:sport, :individual)
    grade = FactoryBot.create(:grade, sport: sport, status: "Closed")
    session = FactoryBot.create(:session)
    venue1 = FactoryBot.create(:venue)
    venue2 = FactoryBot.create(:venue)
    section1 = FactoryBot.create(:section, 
      grade: grade, 
      venue: venue1, 
      session: session)
    section2 = FactoryBot.create(:section, 
      grade: grade, 
      venue: venue2, 
      session: session)
    section3 = FactoryBot.create(:section, 
      grade: grade, 
      venue: venue1, 
      session: session,
      active: false)
    16.times do
      FactoryBot.create(:sport_entry, 
        grade: grade,
        section: section1)
    end
    5.times do
      FactoryBot.create(:sport_entry, 
        grade: grade,
        section: section2)
    end

    FinaliseGradesJob.perform_now(:individual)

    grade.reload
    section1.reload
    section2.reload
    section3.reload
    assert_equal "Allocated", grade.status
    assert_equal 21, grade.entry_limit
    assert_equal 10, section1.number_in_draw
    assert_equal 11, section2.number_in_draw
    assert_equal 0, section3.number_in_draw
    assert_equal 10, section1.sport_entries.count
    assert_equal 11, section2.sport_entries.count
    assert_equal 0, section3.sport_entries.count
  end
end
