# == Schema Information
#
# Table name: sections
#
#  id               :bigint           not null, primary key
#  active           :boolean
#  database_rowid   :integer
#  name             :string(50)       not null
#  number_in_draw   :integer
#  number_of_courts :integer          default(1)
#  results_locked   :boolean          default(FALSE)
#  updated_by       :bigint
#  year_introduced  :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  grade_id         :bigint           default(0), not null
#  session_id       :bigint           default(0), not null
#  venue_id         :bigint           default(0), not null
#
# Indexes
#
#  index_sections_on_name  (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (grade_id => grades.id)
#  fk_rails_...  (session_id => sessions.id)
#  fk_rails_...  (venue_id => venues.id)
#

require "test_helper"

class SectionTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @section = FactoryBot.create(:section, name: "Order1")
  end

  test "should compare sport sections" do
    #comparison against self
    assert_equal 0, @section <=> @section 
    #different name
    other_section = FactoryBot.create(:section, name: "Order2")
    assert_equal -1, @section <=> other_section
  end

  test "should inherit sport name from grade" do
    assert_equal @section.grade.sport_name, @section.sport_name
  end

  test "should inherit venue name from venue" do
    assert_equal @section.venue.name, @section.venue_name
  end

  test "should inherit session name from session" do
    assert_equal @section.session.name, @section.session_name
  end

  test "should provide section session and venue" do
    assert_equal @section.session.name + ' - ' + @section.venue.name, @section.session_and_venue
  end

  test "should list all sport coordinators" do
    vt = FactoryBot.create(:volunteer_type, name: 'Sport Coordinator')
    sc = FactoryBot.create(:volunteer, volunteer_type: vt, section: @section)

    assert @section.sport_coords.include?(sc)
  end

  test "should import sections from file" do
    FactoryBot.create(:grade, name: "Hockey Open B")
    FactoryBot.create(:venue, database_code: "HOCK")
    FactoryBot.create(:session, database_rowid: 1)
    file = fixture_file_upload('section.csv','application/csv')
    
    assert_difference('Section.count') do
      @result = Section.import(file, @user)
    end

    assert_equal 1, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 0, @result[:errors]
  end

  test "should update exiting sections from file" do
    grade = FactoryBot.create(:grade, name: "Hockey Open B")
    venue = FactoryBot.create(:venue, database_code: "HOCK")
    session = FactoryBot.create(:session, database_rowid: 1)
    section = FactoryBot.create(:section, name: 'Hockey Open B1', grade: grade, venue: venue, session: session)
    file = fixture_file_upload('section.csv','application/csv')
    
    assert_no_difference('Section.count') do
      @result = Section.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 1, @result[:updates]
    assert_equal 0, @result[:errors]

    section.reload
    assert_equal 2005, section.year_introduced
  end

  test "should not import sections with errors from file" do
    FactoryBot.create(:grade, name: "Hockey Open B")
    FactoryBot.create(:venue, database_code: "HOCK")
    FactoryBot.create(:session, database_rowid: 1)
    file = fixture_file_upload('invalid_section.csv','application/csv')
    
    assert_no_difference('Section.count') do
      @result = Section.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]
  end

  test "should not update sections with errors from file" do
    grade = FactoryBot.create(:grade, name: "Hockey Open B")
    venue = FactoryBot.create(:venue, database_code: "HOCK")
    session = FactoryBot.create(:session, database_rowid: 1)
    section = FactoryBot.create(:section, name: 'Hockey Open B1', grade: grade, venue: venue, session: session)
    file = fixture_file_upload('invalid_section.csv','application/csv')
    
    assert_no_difference('Section.count') do
      @result = Section.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]

    section.reload
    assert_equal session, section.session
  end
end
