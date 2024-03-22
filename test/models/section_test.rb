# == Schema Information
#
# Table name: sections
#
#  id               :bigint           not null, primary key
#  active           :boolean
#  database_rowid   :integer
#  finals_format    :string(20)
#  name             :string(50)       not null
#  number_in_draw   :integer
#  number_of_courts :integer          default(1)
#  number_of_groups :integer          default(1)
#  results_locked   :boolean          default(FALSE)
#  start_court      :integer          default(1)
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
    sc = FactoryBot.create(:volunteer, volunteer_type: vt)
    sc.sections << @section

    assert @section.sport_coords.include?(sc)
  end

  test "should return the number of available courts" do
    section = FactoryBot.create(:section, number_of_courts: 2)

    assert_equal 2, section.courts_available

    section.number_of_courts = nil

    assert_equal 1, section.courts_available
  end

  test "should calculate the number of teams for a section" do
    grade = FactoryBot.create(:grade, :restricted,
      entry_limit: 15)
    section1 = FactoryBot.create(:section, 
      grade: grade,
      number_of_courts: 0)
    section2 = FactoryBot.create(:section, 
      grade: grade,
      number_of_courts: 2)

    assert_equal 5, section1.teams_allowed
    assert_equal 10, section2.teams_allowed
  end

  test "should import sections from file" do
    FactoryBot.create(:grade, name: "Hockey Open B")
    FactoryBot.create(:venue, database_code: "HOCK")
    FactoryBot.create(:session, database_rowid: 1)
    file = fixture_file_upload('section.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    
    assert_difference('Section.count') do
      @result = Section.import_excel(file, @user)
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
    file = fixture_file_upload('section.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    
    assert_no_difference('Section.count') do
      @result = Section.import_excel(file, @user)
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
    file = fixture_file_upload('invalid_section.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    
    assert_no_difference('Section.count') do
      @result = Section.import_excel(file, @user)
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
    file = fixture_file_upload('invalid_section.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    
    assert_no_difference('Section.count') do
      @result = Section.import_excel(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]

    section.reload
    assert_equal session, section.session
  end

  test "should calculate top 2 finalists" do
    section = FactoryBot.create(:section,
      finals_format: "Top 2",
      number_of_groups: 1)

    entry1 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry2 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry3 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry4 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry5 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry6 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    match1 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 1,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id,
      forfeit_a: true,
      forfeit_b: true
    )
    match2 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 3,
      entry_a_id: entry3.id,
      entry_b_id: entry4.id,
      forfeit_a: true
    )
    match3 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 3,
      entry_a_id: entry5.id,
      entry_b_id: entry6.id,
      forfeit_b: true
    )
    match4 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 4,
      entry_a_id: entry2.id,
      entry_b_id: entry3.id,
      score_a: 1,
      score_b: 1
    )
    match5 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 5,
      entry_a_id: entry4.id,
      entry_b_id: entry5.id,
      score_a: 2,
      score_b: 1
    )
    match6 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 6,
      entry_a_id: entry6.id,
      entry_b_id: entry1.id,
      score_a: 1,
      score_b: 2
    )

    rrl = RoundRobinLadder.new(section)
    section.add_finals_from_ladder(rrl)

    gf = RoundRobinMatch.where(match: 200, section_id: section.id).first
    assert_equal entry4.id, gf.entry_a_id
    assert_equal entry5.id, gf.entry_b_id
  end

  test "should calculate top 4 finalists" do
    section = FactoryBot.create(:section,
      finals_format: "Top 4",
      number_of_groups: 1)

    entry1 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry2 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry3 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry4 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry5 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry6 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    match1 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 1,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id,
      forfeit_a: true,
      forfeit_b: true
    )
    match2 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 3,
      entry_a_id: entry3.id,
      entry_b_id: entry4.id,
      forfeit_a: true
    )
    match3 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 3,
      entry_a_id: entry5.id,
      entry_b_id: entry6.id,
      forfeit_b: true
    )
    match4 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 4,
      entry_a_id: entry2.id,
      entry_b_id: entry3.id,
      score_a: 1,
      score_b: 1
    )
    match5 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 5,
      entry_a_id: entry4.id,
      entry_b_id: entry5.id,
      score_a: 2,
      score_b: 1
    )
    match6 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 6,
      entry_a_id: entry6.id,
      entry_b_id: entry1.id,
      score_a: 1,
      score_b: 2
    )

    rrl = RoundRobinLadder.new(section)
    section.add_finals_from_ladder(rrl)

    sf1 = RoundRobinMatch.where(match: 100, section_id: section.id).first
    sf2 = RoundRobinMatch.where(match: 101, section_id: section.id).first
    assert_equal entry4.id, sf1.entry_a_id
    assert_equal entry2.id, sf1.entry_b_id
    assert_equal entry5.id, sf2.entry_a_id
    assert_equal entry1.id, sf2.entry_b_id
  end

  test "should calculate top 2 in group finalists" do
    section = FactoryBot.create(:section,
      finals_format: "Top 2 in Group",
      number_of_groups: 2)

    entry1 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry2 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry3 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry4 = FactoryBot.create(:sport_entry, section: section, group_number: 2)
    entry5 = FactoryBot.create(:sport_entry, section: section, group_number: 2)
    entry6 = FactoryBot.create(:sport_entry, section: section, group_number: 2)
    match1 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 1,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id,
      forfeit_a: true,
      forfeit_b: true
    )
    match2 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 3,
      entry_a_id: entry3.id,
      entry_b_id: entry4.id,
      forfeit_a: true
    )
    match3 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 3,
      entry_a_id: entry5.id,
      entry_b_id: entry6.id,
      forfeit_b: true
    )
    match4 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 4,
      entry_a_id: entry2.id,
      entry_b_id: entry3.id,
      score_a: 1,
      score_b: 1
    )
    match5 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 5,
      entry_a_id: entry4.id,
      entry_b_id: entry5.id,
      score_a: 2,
      score_b: 1
    )
    match6 = FactoryBot.create(:round_robin_match,     
      section: section,
      match: 6,
      entry_a_id: entry6.id,
      entry_b_id: entry1.id,
      score_a: 1,
      score_b: 2
    )

    rrl = RoundRobinLadder.new(section)
    section.add_finals_from_ladder(rrl)

    sf1 = RoundRobinMatch.where(match: 100, section_id: section.id).first
    sf2 = RoundRobinMatch.where(match: 101, section_id: section.id).first
    assert_equal entry1.id, sf1.entry_a_id
    assert_equal entry5.id, sf1.entry_b_id
    assert_equal entry4.id, sf2.entry_a_id
    assert_equal entry2.id, sf2.entry_b_id
  end

  test "should calculate top in group finalists for 3 groups" do
    section = FactoryBot.create(:section,
      finals_format: "Top in Group",
      number_of_groups: 3)

    entry1 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry2 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry3 = FactoryBot.create(:sport_entry, section: section, group_number: 2)
    entry4 = FactoryBot.create(:sport_entry, section: section, group_number: 2)
    entry5 = FactoryBot.create(:sport_entry, section: section, group_number: 3)
    entry6 = FactoryBot.create(:sport_entry, section: section, group_number: 3)
    match1 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 1,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id,
      forfeit_a: true,
      forfeit_b: true
    )
    match2 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 3,
      entry_a_id: entry3.id,
      entry_b_id: entry4.id,
      forfeit_a: true
    )
    match3 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 3,
      entry_a_id: entry5.id,
      entry_b_id: entry6.id,
      forfeit_b: true
    )
    match4 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 4,
      entry_a_id: entry2.id,
      entry_b_id: entry3.id,
      score_a: 1,
      score_b: 1
    )
    match5 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 5,
      entry_a_id: entry4.id,
      entry_b_id: entry5.id,
      score_a: 2,
      score_b: 1
    )
    match6 = FactoryBot.create(:round_robin_match,
      section: section,
      match: 6,
      entry_a_id: entry6.id,
      entry_b_id: entry1.id,
      score_a: 1,
      score_b: 2
    )

    rrl = RoundRobinLadder.new(section)
    section.add_finals_from_ladder(rrl)

    sf1 = RoundRobinMatch.where(match: 100, section_id: section.id).first
    sf2 = RoundRobinMatch.where(match: 101, section_id: section.id).first
    assert_equal entry1.id, sf1.entry_a_id
    assert_equal entry5.id, sf1.entry_b_id
    assert_equal entry4.id, sf2.entry_a_id
    assert_equal entry2.id, sf2.entry_b_id
  end

  test "should calculate top in group finalists for 4 groups" do
    section = FactoryBot.create(:section,
      finals_format: "Top in Group",
      number_of_groups: 4)

    entry1 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry2 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry3 = FactoryBot.create(:sport_entry, section: section, group_number: 2)
    entry4 = FactoryBot.create(:sport_entry, section: section, group_number: 2)
    entry5 = FactoryBot.create(:sport_entry, section: section, group_number: 3)
    entry6 = FactoryBot.create(:sport_entry, section: section, group_number: 3)
    entry7 = FactoryBot.create(:sport_entry, section: section, group_number: 4)
    entry8 = FactoryBot.create(:sport_entry, section: section, group_number: 4)
    match1 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 1,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id,
      forfeit_a: true,
      forfeit_b: true
    )
    match2 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 3,
      entry_a_id: entry3.id,
      entry_b_id: entry4.id,
      forfeit_a: true
    )
    match3 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 3,
      entry_a_id: entry5.id,
      entry_b_id: entry6.id,
      forfeit_b: true
    )
    match4 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 4,
      entry_a_id: entry7.id,
      entry_b_id: entry8.id,
      score_a: 1,
      score_b: 1
    )
    match5 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 5,
      entry_a_id: entry2.id,
      entry_b_id: entry3.id,
      score_a: 2,
      score_b: 1
    )
    match6 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 6,
      entry_a_id: entry4.id,
      entry_b_id: entry5.id,
      score_a: 1,
      score_b: 2
    )
    match7 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 7,
      entry_a_id: entry6.id,
      entry_b_id: entry7.id,
      score_a: 1,
      score_b: 2
    )
    match8 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 8,
      entry_a_id: entry8.id,
      entry_b_id: entry1.id,
      score_a: 1,
      score_b: 3
    )

    rrl = RoundRobinLadder.new(section)
    section.add_finals_from_ladder(rrl)

    sf1 = RoundRobinMatch.where(match: 100, section_id: section.id).first
    sf2 = RoundRobinMatch.where(match: 101, section_id: section.id).first
    assert_equal entry1.id, sf1.entry_a_id
    assert_equal entry5.id, sf1.entry_b_id
    assert_equal entry4.id, sf2.entry_a_id
    assert_equal entry7.id, sf2.entry_b_id
  end

  test "should create grand final from semi-final winners" do
    section = FactoryBot.create(:section)

    entry1 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry2 = FactoryBot.create(:sport_entry, section: section, group_number: 2)
    entry3 = FactoryBot.create(:sport_entry, section: section, group_number: 3)
    entry4 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    match100 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 100,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id,
      score_a: 2,
      score_b: 1
    )
    match101 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 101,
      entry_a_id: entry3.id,
      entry_b_id: entry4.id,
      score_a: 1,
      score_b: 2
    )

    section.add_finalists_from_semis

    gf = RoundRobinMatch.where(match: 200, section_id: section.id).first
    assert_equal entry1.id, gf.entry_a_id
    assert_equal entry4.id, gf.entry_b_id
  end

  test "should create grand final from semi-final winners 2" do
    section = FactoryBot.create(:section)

    entry1 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry2 = FactoryBot.create(:sport_entry, section: section, group_number: 2)
    entry3 = FactoryBot.create(:sport_entry, section: section, group_number: 3)
    entry4 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    match100 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 100,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id,
      score_a: 1,
      score_b: 2
    )
    match101 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 101,
      entry_a_id: entry3.id,
      entry_b_id: entry4.id,
      score_a: 2,
      score_b: 1
    )

    section.add_finalists_from_semis

    gf = RoundRobinMatch.where(match: 200, section_id: section.id).first
    assert_equal entry2.id, gf.entry_a_id
    assert_equal entry3.id, gf.entry_b_id
  end

  test "should reset round robin draw" do
    section = FactoryBot.create(:section)

    entry1 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry2 = FactoryBot.create(:sport_entry, section: section, group_number: 2)
    entry3 = FactoryBot.create(:sport_entry, section: section, group_number: 3)
    entry4 = FactoryBot.create(:sport_entry, section: section, group_number: 1)
    entry5 = FactoryBot.create(:sport_entry, section: section, group_number: 2)
    entry6 = FactoryBot.create(:sport_entry, section: section, group_number: 3)
    match1 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 1,
      entry_a_id: entry1.id,
      entry_b_id: entry2.id,
      forfeit_a: true,
      forfeit_b: true
    )
    match2 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 3,
      entry_a_id: entry3.id,
      entry_b_id: entry4.id,
      forfeit_a: true
    )
    match3 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 3,
      entry_a_id: entry5.id,
      entry_b_id: entry6.id,
      forfeit_b: true
    )
    match4 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 4,
      entry_a_id: entry2.id,
      entry_b_id: entry3.id,
      score_a: 1,
      score_b: 1
    )
    match5 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 5,
      entry_a_id: entry4.id,
      entry_b_id: entry5.id,
      score_a: 2,
      score_b: 1
    )
    match6 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 6,
      entry_a_id: entry6.id,
      entry_b_id: entry1.id,
      score_a: 1,
      score_b: 2
    )
    match200 = FactoryBot.create(:round_robin_match, 
      section: section,
      match: 200,
      entry_a_id: entry1.id,
      entry_b_id: entry4.id,
      score_a: 1,
      score_b: 2
    )

    section.reset_round_robin_draw!

    match1.reload
    assert_equal 0, match1.score_a
    assert_equal 0, match1.score_b
    assert_equal false, match1.forfeit_a
    assert_equal false, match1.forfeit_b

    match2.reload
    assert_equal 0, match2.score_a
    assert_equal 0, match2.score_b
    assert_equal false, match2.forfeit_a
    assert_equal false, match2.forfeit_b

    match3.reload
    assert_equal 0, match3.score_a
    assert_equal 0, match3.score_b
    assert_equal false, match3.forfeit_a
    assert_equal false, match3.forfeit_b

    match4.reload
    assert_equal 0, match4.score_a
    assert_equal 0, match4.score_b
    assert_equal false, match4.forfeit_a
    assert_equal false, match4.forfeit_b

    match5.reload
    assert_equal 0, match5.score_a
    assert_equal 0, match5.score_b
    assert_equal false, match5.forfeit_a
    assert_equal false, match5.forfeit_b

    match6.reload
    assert_equal 0, match6.score_a
    assert_equal 0, match6.score_b
    assert_equal false, match6.forfeit_a
    assert_equal false, match6.forfeit_b

    gf = RoundRobinMatch.where(id: match200.id).first
    assert_nil gf
  end
end
