# == Schema Information
#
# Table name: sport_entries
#
#  id              :bigint           not null, primary key
#  chance_of_entry :integer          default(100)
#  multiple_teams  :boolean          default(FALSE)
#  status          :string(20)       default("Requested")
#  team_number     :integer          default(1), not null
#  updated_by      :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  captaincy_id    :bigint
#  grade_id        :bigint           not null
#  group_id        :bigint           not null
#  section_id      :bigint
#
# Indexes
#
#  index_sport_entries_on_grade_id  (grade_id)
#  index_sport_entries_on_group_id  (group_id)
#
# Foreign Keys
#
#  fk_rails_...  (grade_id => grades.id)
#  fk_rails_...  (group_id => groups.id)
#
require "test_helper"

class SportEntryTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def setup
    @user = FactoryBot.create(:user, :admin)
    @setting = FactoryBot.create(:setting)
    @entry = FactoryBot.create(:sport_entry)
  end

  def test_sport_entry_compare
    #comparison against self
    assert_equal 0, @entry <=> @entry
    #same grade, different id
    entry_in_same_grade = FactoryBot.create(:sport_entry, grade: @entry.grade)
    assert_equal 1, entry_in_same_grade <=> @entry
    #different grade
    other_entry = FactoryBot.create(:sport_entry)
    assert_equal -1, @entry <=> other_entry
  end

  def test_sport_entry_sport
    assert_equal @entry.grade.sport, @entry.sport
  end

  def test_sport_entry_grade_type
    assert_equal @entry.grade.grade_type, @entry.grade_type
  end

#  def test_sport_entry_session
#    assert_equal @entry.grade.session, @entry.session
#  end

  def test_sport_entry_name
    group = FactoryBot.create(:group)
    participant1 = FactoryBot.create(:participant, group: group)
    participant2 = FactoryBot.create(:participant, group: group)
    singles_grade = FactoryBot.create(:grade,
                            grade_type: "Singles")
    doubles_grade = FactoryBot.create(:grade,
                            grade_type: "Doubles")
    team_grade = FactoryBot.create(:grade,
                         grade_type: "Team")
    
    #singles entry with enough participants
    singles_entry = FactoryBot.create(:sport_entry, 
                            group: group,
                            grade: singles_grade)
    singles_entry.participants << participant1
    singles_entry.save
    
    assert_equal participant1.name, singles_entry.name

    #singles entry with no participants
    singles_entry = FactoryBot.create(:sport_entry, 
                            group: group,
                            grade: singles_grade)

    assert_equal "Add a participant", singles_entry.name

    #doubles entry with enough participants
    doubles_entry = FactoryBot.create(:sport_entry, 
                            group: group,
                            grade: doubles_grade)
    doubles_entry.participants << participant1
    doubles_entry.participants << participant2
    doubles_entry.save
    
    assert_equal participant1.name + " / " + participant2.name, doubles_entry.name

    #doubles entry with not enough participants
    doubles_entry = FactoryBot.create(:sport_entry, 
                            group: group,
                            grade: doubles_grade)
    doubles_entry.participants << participant1
    doubles_entry.save

    assert_equal "Add participant(s)", doubles_entry.name

    #team entry
    team_entry = FactoryBot.create(:sport_entry, 
                         group: group,
                         grade: team_grade)

    assert_equal group.short_name, team_entry.name
  end

  def test_sport_entry_requires_participants
    group = FactoryBot.create(:group)
    participant1 = FactoryBot.create(:participant, group: group)
    participant2 = FactoryBot.create(:participant, group: group)
    singles_grade = FactoryBot.create(:grade,
                            grade_type: "Singles",
                            min_participants: 1)
    doubles_grade = FactoryBot.create(:grade,
                            grade_type: "Doubles",
                            min_participants: 2)
    team_grade = FactoryBot.create(:grade,
                         grade_type: "Team",
                         min_participants: 0)
    
    #singles entry with enough participants
    singles_entry = FactoryBot.create(:sport_entry, 
                            group: group,
                            grade: singles_grade)
    singles_entry.participants << participant1
    singles_entry.save

    assert !singles_entry.requires_participants?

    #singles entry with no participants
    singles_entry = FactoryBot.create(:sport_entry, 
                            group: group,
                            grade: singles_grade)

    assert singles_entry.requires_participants?
    
    #doubles entry with enough participants
    doubles_entry = FactoryBot.create(:sport_entry, 
                            group: group,
                            grade: doubles_grade)
    doubles_entry.participants << participant1
    doubles_entry.participants << participant2
    doubles_entry.save
    
    assert !doubles_entry.requires_participants?

    #doubles entry with not enough participants
    doubles_entry = FactoryBot.create(:sport_entry, 
                            group: group,
                            grade: doubles_grade)
    doubles_entry.participants << participant1
    doubles_entry.save
    
    assert doubles_entry.requires_participants?

    #team entry
    team_entry = FactoryBot.create(:sport_entry, 
                         group: group,
                         grade: team_grade)

    assert !team_entry.requires_participants?
  end

  def test_sport_entry_requires_males
    group = FactoryBot.create(:group)
    male_participant = FactoryBot.create(:participant, 
      group: group,
      gender: "M")
    mens_grade = FactoryBot.create(:grade,
                            grade_type: "Singles",
                            min_males: 1)
    
    #mens entry with enough males
    mens_entry = FactoryBot.create(:sport_entry, 
                            group: group,
                            grade: mens_grade)
    mens_entry.participants << male_participant
    mens_entry.save

    assert !mens_entry.requires_males?

    #mens entry with no participants
    mens_entry = FactoryBot.create(:sport_entry, 
                            group: group,
                            grade: mens_grade)

    assert mens_entry.requires_males?
  end

  def test_sport_entry_requires_females
    group = FactoryBot.create(:group)
    female_participant = FactoryBot.create(:participant, 
      group: group,
      gender: "F")
    ladies_grade = FactoryBot.create(:grade,
                            grade_type: "Singles",
                            min_females: 1)
    
    #ladies entry with enough females
    ladies_entry = FactoryBot.create(:sport_entry, 
                            group: group,
                            grade: ladies_grade)
    ladies_entry.participants << female_participant
    ladies_entry.save

    assert !ladies_entry.requires_females?

    #ladies entry with no participants
    ladies_entry = FactoryBot.create(:sport_entry, 
                            group: group,
                            grade: ladies_grade)

    assert ladies_entry.requires_females?
  end

  test "sport entry should identify issues" do
    group = FactoryBot.create(:group)
    male_participant = FactoryBot.create(:participant, 
      group: group,
      gender: "M")
    female_participant = FactoryBot.create(:participant, 
      group: group,
      gender: "F")
    mens_grade = FactoryBot.create(:grade,
                            grade_type: "Singles",
                            min_males: 1,
                            min_participants: 1)
    ladies_grade = FactoryBot.create(:grade,
                            grade_type: "Singles",
                            min_females: 1,
                            min_participants: 1)
    
    #mens entry with no participants
    mens_entry = FactoryBot.create(:sport_entry, 
      group: group,
      grade: mens_grade)

    assert 'Not enough males', mens_entry.issues[0]
    assert 'Not enough participants', mens_entry.issues[1]
    
    #ladies entry with no participants
    ladies_entry = FactoryBot.create(:sport_entry, 
      group: group,
      grade: ladies_grade)

    assert 'Not enough females', ladies_entry.issues[0]
    assert 'Not enough participants', ladies_entry.issues[1]
  end

  test "sport entry should know of venue and session" do
    #entry has sport section
    section = FactoryBot.create(:section)
    entry = FactoryBot.create(:sport_entry,
                    grade: section.grade,
                    section: section)

    assert entry.venue_known?
    assert entry.session_known?
    
    #entry grade only one possible venue and session
    section1 = FactoryBot.create(:section)
    section2 = FactoryBot.create(:section, 
                       grade: section1.grade,
                       venue: section1.venue,
                       session: section1.session)
    entry = FactoryBot.create(:sport_entry,
                    grade: section1.grade)

    assert entry.venue_known?
    assert entry.session_known?
    
    #entry grade has many possible venues and sessions
    section1 = FactoryBot.create(:section)
    section2 = FactoryBot.create(:section, 
                       grade: section1.grade)
    entry = FactoryBot.create(:sport_entry,
                    grade: section1.grade)

    assert !entry.venue_known?
    assert !entry.session_known?
  end

  test "sport entry should know name of venue and session" do
    #entry has sport section
    section = FactoryBot.create(:section)
    entry = FactoryBot.create(:sport_entry,
                    grade: section.grade,
                    section: section)

    assert_equal section.venue.name, entry.venue_name
    assert_equal section.session.name, entry.session_name
    
    #entry grade only one possible venue and session
    section1 = FactoryBot.create(:section)
    section2 = FactoryBot.create(:section, 
                       grade: section1.grade,
                       venue: section1.venue,
                       session: section1.session)
    entry = FactoryBot.create(:sport_entry,
                    grade: section1.grade)

    assert_equal section1.venue.name, entry.venue_name
    assert_equal section1.session.name, entry.session_name
    
    #entry grade has many possible venues and sessions
    section1 = FactoryBot.create(:section)
    section2 = FactoryBot.create(:section, 
                       grade: section1.grade)
    entry = FactoryBot.create(:sport_entry,
                    grade: section1.grade)

    assert_equal "(not final)", entry.venue_name
    assert_equal "(not final)", entry.session_name
  end

#  def test_sport_entry_venue
    #entry has sport section
#    section = FactoryBot.create(:section)
#    entry = FactoryBot.create(:sport_entry,
#                    grade: section.grade,
#                    section: section)

#    assert_equal section.venue, entry.venue

    #entry grade only one possible venue
#    section1 = FactoryBot.create(:section)
#    section2 = FactoryBot.create(:section, 
#                       grade: section1.grade,
#                       venue: section1.venue)
#    entry = FactoryBot.create(:sport_entry,
#                    grade: section1.grade)

#    assert_equal section1.venue, entry.venue
    
    #entry grade has many possible venues
#    section1 = FactoryBot.create(:section)
#    section2 = FactoryBot.create(:section, 
#                       grade: section1.grade)
#    entry = FactoryBot.create(:sport_entry,
#                    grade: section1.grade)

#    assert_equal section1.venue, entry.venue
#  end

  def test_should_not_create_entry_when_group_limit_reached
    grade_with_few_entries_allowed = FactoryBot.create(:grade,
      grade_type: "Team",
      sport: FactoryBot.create(:sport,
        max_team_entries_group: 1,
        max_indiv_entries_group: 0))
    group = FactoryBot.create(:group)
    FactoryBot.create(:sport_entry,
                   group: group,
                   grade: grade_with_few_entries_allowed)
    
    e = SportEntry.new(grade:   grade_with_few_entries_allowed, 
                       status:        "Entered", 
                       group:         group)
    assert !e.save     
    assert e.errors[:grade_id].any?
  end
  
#  def test_should_determine_allocation_chance
    # All entries for the grade have been allocated
#    grade_with_zero_availability = FactoryBot.create(:grade,
#                                    entry_limit: 1)
#    FactoryBot.create(:sport_entry, 
#                   grade: grade_with_zero_availability)
#    entry = FactoryBot.create(:sport_entry, 
#                    grade: grade_with_zero_availability,
#                    status: "Requested")

#    assert_equal 0, entry.allocation_chance
    
    # Grade has availability - everyone wins
#    grade_with_availability = FactoryBot.create(:grade,
#                                    entry_limit: 1)
#    entry = FactoryBot.create(:sport_entry, 
#                    grade: grade_with_availability,
#                    status: "Requested")
                    
#    assert_equal 100, entry.allocation_chance
    
    # Fewer groups than limit - high_priority
#    grade_with_fewer_groups_than_limit = FactoryBot.create(:grade,
#                                                 entry_limit: 4)
#    high_entry = []
#    low_entry = []
#    1.upto 3 do |number|
#      high_entry[number] = FactoryBot.create(:sport_entry, 
#                                   grade: grade_with_fewer_groups_than_limit,
#                                   status: "Requested",
#                                   priority: 5)
#      low_entry[number] = FactoryBot.create(:sport_entry, 
#                                  group: high_entry[number].group,
#                                  grade: grade_with_fewer_groups_than_limit,
#                                  status: "Requested",
#                                  priority: 1)
#    end

 #   entry = SportEntry.find(high_entry[1].id)
 #   assert_equal 100, entry.allocation_chance
    
    # Fewer groups than limit - low_priority
 #   entry = SportEntry.find(low_entry[1].id)
 #   assert 0 < entry.allocation_chance
 #   assert 100 > entry.allocation_chance
    
    # #groups equals limit - high_priority
 #   grade_with_groups_equals_limit = FactoryBot.create(:grade,
 #                                            entry_limit: 4)
 #   high_entry = []
 #   low_entry = []
 #   1.upto 4 do |number|
 #     high_entry[number] = FactoryBot.create(:sport_entry, 
 #                                  grade: grade_with_groups_equals_limit,
 #                                  status: "Requested",
 #                                  priority: 5)
 #     low_entry[number] = FactoryBot.create(:sport_entry, 
 #                                 group: high_entry[number].group,
 #                                 grade: grade_with_groups_equals_limit,
 #                                 status: "Requested",
 #                                 priority: 1)
 #   end

#    entry = SportEntry.find(high_entry[1].id)
#    assert_equal 100, entry.allocation_chance
    
    # #groups equals limit - low_priority
#    entry = SportEntry.find(low_entry[1].id)
#    assert_equal 0, entry.allocation_chance
    
    # Not enough sports for each church - high_priority
#    grade_with_limited_availability = FactoryBot.create(:grade,
#                                              entry_limit: 3)
#    high_entry = []
#    low_entry = []
#    1.upto 4 do |number|
#      high_entry[number] = FactoryBot.create(:sport_entry, 
#                                   grade: grade_with_limited_availability,
#                                   status: "Requested",
#                                   priority: 5)
#      low_entry[number] = FactoryBot.create(:sport_entry, 
#                                  group: high_entry[number].group,
#                                  grade: grade_with_limited_availability,
#                                  status: "Requested",
#                                  priority: 1)
#    end

#    entry = SportEntry.find(high_entry[1].id)
#    assert 0 < entry.allocation_chance
#    assert 100 > entry.allocation_chance
   
    # Not enough sports for each church - low_priority
#    entry = SportEntry.find(low_entry[1].id)
#    assert_equal 0, entry.allocation_chance
#  end
  
#  test "section name should use section name when section exists" do
#    section = FactoryBot.create(:section)
#    entry = FactoryBot.create(:sport_entry, grade_id: section.grade_id, section_id: section.id)
    
#    assert_equal section.name, entry.section_name
#  end
  
#  test "section name should use grade name when section does not exist" do
#    entry = FactoryBot.create(:sport_entry)
    
#    assert_equal entry.grade.name, entry.section_name
#  end

  # Don't know why, but this test fails in the context of the whole test suite
  # even though it passes when just testing this file
    
  # test "entry can take participants when fewer participants than max" do
    # grade = FactoryBot.create(:grade, max_participants: 2)
    # entry1 = FactoryBot.create(:sport_entry, grade_id: grade.id)
    # entry2 = FactoryBot.create(:sport_entry, grade_id: grade.id)
    # participant = FactoryBot.create(:participant)
    # entry2.participants << participant
    # 
    # assert_equal true, entry2.can_take_participants? 
    # assert_equal true, entry1.can_take_participants? 
  # end
  
  test "entry can not take participants when at max participants" do
    grade = FactoryBot.create(:grade, max_participants: 1)
    entry = FactoryBot.create(:sport_entry, grade: grade)
    participant = FactoryBot.create(:participant)
    entry.participants << participant
    
    assert !entry.can_take_participants? 
  end

  test "should reset sport entry status to requested" do
    @entry.reset!
    @entry.reload

    assert_equal 'Requested', @entry.status
  end

  test "should reject sport entry status to waiting list" do
    @entry.reject!
    @entry.reload

    assert_equal 'Waiting List', @entry.status
  end

  test "should set sport entry status to needing confirmation" do
    @entry.require_confirmation!
    @entry.reload

    assert_equal 'To Be Confirmed', @entry.status
  end

  test "should set sport entry status to entered" do
    @entry.status = 'Requested'
    @entry.enter!
    @entry.reload

    assert_equal 'Entered', @entry.status
  end
end
