require "test_helper"

class AllocateRestrictedJobTest < ActiveJob::TestCase
  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @setting = FactoryBot.create(:setting)
  end

  test "restricted grades are allocated" do
    sport = FactoryBot.create(:sport, :team)
    grade = FactoryBot.create(:grade, :restricted, sport: sport)
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

    AllocateRestrictedJob.perform_now

    grade.reload
    section1.reload
    section2.reload
    assert_equal "Closed", grade.status
  end
end
