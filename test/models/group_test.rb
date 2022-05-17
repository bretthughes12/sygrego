# == Schema Information
#
# Table name: groups
#
#  id               :bigint           not null, primary key
#  abbr             :string(4)        not null
#  address          :string(200)      not null
#  admin_use        :boolean          default(FALSE)
#  age_demographic  :string(40)
#  allocation_bonus :integer          default(0)
#  coming           :boolean          default(TRUE)
#  database_rowid   :integer
#  denomination     :string(40)       not null
#  email            :string(100)
#  group_focus      :string(100)
#  last_year        :boolean          default(FALSE)
#  late_fees        :decimal(8, 2)    default(0.0)
#  lock_version     :integer          default(0)
#  name             :string(100)      not null
#  new_group        :boolean          default(TRUE)
#  phone_number     :string(20)
#  postcode         :integer          not null
#  short_name       :string(50)       not null
#  status           :string(12)       default("Stale")
#  suburb           :string(40)       not null
#  trading_name     :string(100)      not null
#  updated_by       :bigint
#  website          :string(100)
#  years_attended   :integer          default(0)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_groups_on_abbr          (abbr) UNIQUE
#  index_groups_on_name          (name) UNIQUE
#  index_groups_on_short_name    (short_name) UNIQUE
#  index_groups_on_trading_name  (trading_name) UNIQUE
#

require "test_helper"

class GroupTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @setting = FactoryBot.create(:setting)
    @group = FactoryBot.create(:group, name: "Order1")
    FactoryBot.create(:event_detail, group: @group)
  end

  test "should compare groups" do
    #comparison against self
    assert_equal 0, @group <=> @group 
    #different name
    other_group = FactoryBot.create(:group, name: "Order2")
    assert_equal -1, @group <=> other_group
  end

  test "should show status with short_name" do
    #all good
    @group.short_name = "Springfield"
    @group.status = "Accepted"
    @group.coming = true
    assert_equal 'Springfield', @group.short_name_with_status 

    #not coming
    @group.coming = false
    assert_equal 'Springfield (Not coming)', @group.short_name_with_status 

    #stale
    @group.status = "Stale"
    assert_equal 'Springfield (Stale)', @group.short_name_with_status 
  end

  def test_group_deposit
    # group expects fewer than 20 (small group)
    group = FactoryBot.create(:group)
    event_detail = FactoryBot.create(:event_detail, 
      estimated_numbers: 19, 
      group: group)
    assert_equal 150, group.deposit

    # group expects no one coming
    event_detail = FactoryBot.create(:event_detail, 
      estimated_numbers: 0, 
      group: group)
    assert_equal 150, group.deposit
    
    # medium group 
    event_detail = FactoryBot.create(:event_detail, 
      estimated_numbers: 20, 
      group: group)
    assert_equal 300, group.deposit
    
    # medium group (upper boundary)
    event_detail = FactoryBot.create(:event_detail, 
      estimated_numbers: 39, 
      group: group)
    assert_equal 300, group.deposit
    
    # large
    event_detail = FactoryBot.create(:event_detail, 
      estimated_numbers: 40, 
      group: group)
    assert_equal 600, group.deposit
    
    # admin
    group.admin_use = true
    assert_equal 0, group.deposit
  end

  def test_group_fees
    #group has people registered
    group = FactoryBot.create(:group)
    event_detail = FactoryBot.create(:event_detail, 
      estimated_numbers: 20, 
      group: group)
    5.times do
      FactoryBot.create(:participant, 
                     group: group, 
                     coming: true)
    end
    group.reload

    assert group.fees > @setting.full_fee
    
    #group has one participant, who is not coming
    group_with_noone_coming = FactoryBot.create(:group)
    event_detail = FactoryBot.create(:event_detail, 
      estimated_numbers: 20, 
      group: group_with_noone_coming)
    FactoryBot.create(:participant, 
                   group: group_with_noone_coming, 
                   coming: false)
    group_with_noone_coming.reload

    assert_equal 0, group_with_noone_coming.fees
    
    #group has one normal camper - fees is not greater than deposit
    group_with_one_coming = FactoryBot.create(:group)
    event_detail = FactoryBot.create(:event_detail, 
      estimated_numbers: 20, 
      group: group_with_one_coming)
    FactoryBot.create(:participant, 
                   group: group_with_one_coming, 
                   coming: true)
    group_with_one_coming.reload

    assert_equal 0, group_with_one_coming.fees
    
    #group with no participants
    group_with_no_participants = FactoryBot.create(:group)
    event_detail = FactoryBot.create(:event_detail, 
      estimated_numbers: 20, 
      group: group_with_no_participants)

    assert_equal 0, group_with_no_participants.fees
  end

  test "should calculate the amount paid" do
    3.times do
      FactoryBot.create(:payment, group: @group, amount: 10.0)
    end

    assert_equal 30.0, @group.amount_paid
  end

  test "should calculate the amount payable" do
    group = FactoryBot.create(:group)
    event_detail = FactoryBot.create(:event_detail, 
      estimated_numbers: 20, 
      group: group)
    5.times do
      FactoryBot.create(:participant, 
                     group: group, 
                     coming: true)
    end
    group.reload

    assert_equal 400.0, group.total_amount_payable
  end

  test "should calculate the amount outstanding" do
    group = FactoryBot.create(:group)
    event_detail = FactoryBot.create(:event_detail, 
      estimated_numbers: 20, 
      group: group)
    5.times do
      FactoryBot.create(:participant, 
                     group: group, 
                     coming: true)
    end
    3.times do
      FactoryBot.create(:payment, group: group, amount: 10.0)
    end
    group.reload

    assert_equal 370.0, group.amount_outstanding
  end

  test "should allow 2 group coordinators" do
    #at present this is always '2'
    assert_equal 2, @group.coordinators_allowed
  end

  def test_division_boundaries
    #Small church
    small_church = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: small_church)
    @setting.small_division_ceiling.times do
      FactoryBot.create(:participant, 
                     group: small_church, 
                     coming: true, 
                     spectator: false)  
    end
    small_church.reload

    assert_equal "Small Churches", small_church.division
    assert_equal 2, small_church.free_helpers

    #Medium church
    medium_church_low = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: medium_church_low)
    (@setting.small_division_ceiling + 1).times do
      FactoryBot.create(:participant, 
                     group_id: medium_church_low.id, 
                     coming: true, 
                     spectator: false)  
    end
    medium_church_low.reload

    medium_church_high = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: medium_church_high)
    @setting.medium_division_ceiling.times do
      FactoryBot.create(:participant, 
                     group: medium_church_high, 
                     coming: true, 
                     spectator: false)  
    end
    medium_church_high.reload

    assert_equal "Medium Churches", medium_church_low.division
    assert_equal "Medium Churches", medium_church_high.division
    assert_equal 4, medium_church_low.free_helpers
    
    #Large church
    large_church = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: large_church)
    (@setting.medium_division_ceiling + 1).times do
      FactoryBot.create(:participant, 
                     group: large_church, 
                     coming: true, 
                     spectator: false)  
    end
    large_church.reload

    assert_equal "Large Churches", large_church.division
    assert_equal 6, large_church.free_helpers
  end
  
  test "divisions should list all groups" do
    FactoryBot.create(:group)
    divisions = Group.divisions

    assert divisions["Small Churches"] > 0
  end
  
  test "group divisions should include all groups" do
    group = FactoryBot.create(:group)
    divisions = Group.group_divisions

    assert_equal "Small Churches", divisions[group.id]
  end

  test "should show mysyg status" do
    ms = FactoryBot.create(:mysyg_setting, mysyg_open: true)
    assert_equal 'Open', ms.group.mysyg_status

    ms.mysyg_open = false
    ms.mysyg_enabled = true
    assert_equal 'Enabled', ms.group.mysyg_status

    ms.mysyg_enabled = false
    assert_equal 'Not enabled', ms.group.mysyg_status
  end

  test "should determine participants allowed per session" do
    # based on estimated numbers
    ed = FactoryBot.create(:event_detail, estimated_numbers: 10)
    assert_equal 15, ed.group.participants_allowed_per_session

    # based on actual numbers
    12.times do
      FactoryBot.create(:participant, group: ed.group)
    end
    ed.group.reload
    assert_equal 18, ed.group.participants_allowed_per_session
  end

  test "should calculate the number playing sport" do
    group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: group)
    12.times do
      FactoryBot.create(:participant, 
        group: group,
        spectator: false,
        status: 'Accepted',
        coming: true)
    end
    group.reload
    assert_equal 12, group.number_playing_sport
  end

  test "should determine helpers allowed" do
    # basic number
    group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: group)
    assert_equal 0, group.helpers_allowed

    # larger groups
    40.times do
      FactoryBot.create(:participant, 
        group: group,
        spectator: false,
        status: 'Accepted',
        coming: true)
    end
    group.reload
    assert_equal 8, group.helpers_allowed
  end

  test "should calculate the helper rebate" do
    group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: group)
    80.times do
      FactoryBot.create(:participant, 
        group: group,
        spectator: false,
        status: 'Accepted',
        coming: true)
    end
    8.times do
      FactoryBot.create(:participant, 
        group: group,
        spectator: true,
        helper: true,
        status: 'Accepted',
        coming: true)
    end

    group.reload
    assert_equal 180, group.helper_rebate
  end

  test "should aggregate church reps" do
    cr_role = FactoryBot.create(:role, "church_rep")
    cr1 = FactoryBot.create(:user)
    cr2 = FactoryBot.create(:user)
    cr1.roles << cr_role
    cr2.roles << cr_role
    gc = FactoryBot.create(:user, :gc)
    @group.users << cr1
    @group.users << cr2
    @group.users << gc

    assert @group.church_reps.include?(cr1)
    assert @group.church_reps.include?(cr2)
    assert !@group.church_reps.include?(gc)
    assert_equal cr1, @group.church_rep
    assert_equal cr1.name, @group.church_rep_name
    assert_equal cr1.phone_number, @group.church_rep_phone_number
    assert_equal cr1.wwcc_number, @group.church_rep_wwcc
  end

  test "should aggregate gcs" do
    gc_role = FactoryBot.create(:role, "gc")
    cr = FactoryBot.create(:user, :church_rep)
    gc1 = FactoryBot.create(:user)
    gc2 = FactoryBot.create(:user)
    gc1.roles << gc_role
    gc2.roles << gc_role
    @group.users << cr
    @group.users << gc1
    @group.users << gc2

    assert @group.gcs.include?(gc1)
    assert @group.gcs.include?(gc2)
    assert !@group.gcs.include?(cr)
    assert_equal gc1, @group.gc
    assert_equal gc1.name, @group.gc_name
    assert_equal gc1.phone_number, @group.gc_phone_number
    assert_equal gc1.wwcc_number, @group.gc_wwcc
  end

  def test_should_be_active_with_a_non_stale_user
    active_group = FactoryBot.create(:group)
    active_group.users << FactoryBot.create(:user)
    
    assert active_group.active
  end

  def test_should_not_be_active_with_no_non_stale_users
    inactive_group = FactoryBot.create(:group)
    inactive_group.users << FactoryBot.create(:user, status: 'Stale')
    
    assert !inactive_group.active
  end
  
  test "email recipients should include email of fresh user" do
    group = FactoryBot.create(:group)
    fresh_user = FactoryBot.create(:user, status: 'Verified')
    stale_user = FactoryBot.create(:user, status: 'Stale')

    group.users << fresh_user
    group.users << stale_user

    assert group.email_recipients.include?(fresh_user.email)
  end
  
  test "email recipients should not include email of stale user" do
    group = FactoryBot.create(:group)
    fresh_user = FactoryBot.create(:user, status: 'Verified')
    stale_user = FactoryBot.create(:user, status: 'Stale')

    group.users << fresh_user
    group.users << stale_user

    assert !group.email_recipients.include?(stale_user.email)
  end

  def test_group_entries_requiring_participants
    other_group = FactoryBot.create(:group)
    participant1 = FactoryBot.create(:participant, group: @group)
    participant2 = FactoryBot.create(:participant, group: @group)
    singles_grade = FactoryBot.create(:grade,
                            grade_type: "Singles",
                            min_participants: 1)
    doubles_grade = FactoryBot.create(:grade,
                            grade_type: "Doubles",
                            min_participants: 2)
    team_grade = FactoryBot.create(:grade,
                         grade_type: "Team",
                         min_participants: 0)

    singles_entry_with_participants = FactoryBot.create(:sport_entry, 
                                              group: @group,
                                              grade: singles_grade)
    singles_entry_with_participants.participants << participant1
    singles_entry_with_participants.save

    singles_entry_with_no_participants = FactoryBot.create(:sport_entry, 
                                                 group: @group,
                                                 grade: singles_grade)

    doubles_entry_with_two_participants = FactoryBot.create(:sport_entry, 
                                                  group: @group,
                                                  grade: doubles_grade)
    doubles_entry_with_two_participants.participants << participant1
    doubles_entry_with_two_participants.participants << participant2
    doubles_entry_with_two_participants.save

    doubles_entry_with_one_participant = FactoryBot.create(:sport_entry, 
                                                  group: @group,
                                                  grade: doubles_grade)
    doubles_entry_with_one_participant.participants << participant1
    doubles_entry_with_one_participant.save

    team_entry = FactoryBot.create(:sport_entry, 
                         group: @group,
                         grade: team_grade)

    #singles entry with enough participants
    assert !@group.entries_requiring_participants.include?(singles_entry_with_participants)

    #singles entry with no participants
    assert @group.entries_requiring_participants.include?(singles_entry_with_no_participants)

    #doubles entry with enough participants
    assert !@group.entries_requiring_participants.include?(doubles_entry_with_two_participants)

    #doubles entry with not enough participants
    assert @group.entries_requiring_participants.include?(doubles_entry_with_one_participant)

    #team entry
    assert !@group.entries_requiring_participants.include?(team_entry)

    #another group won't see my entries
    assert !other_group.entries_requiring_participants.include?(singles_entry_with_no_participants)
  end

  test "should list all entries requiring males" do
    other_group = FactoryBot.create(:group)
    participant1 = FactoryBot.create(:participant, group: @group, gender: "M")
    participant2 = FactoryBot.create(:participant, group: @group, gender: "F")
    mens_grade = FactoryBot.create(:grade,
      gender_type: "Mens",
      min_participants: 1,
      max_participants: 1,
      min_males: 1)
    ladies_grade = FactoryBot.create(:grade,
      gender_type: "Ladies",
      min_participants: 1,
      max_participants: 1,
      min_females: 1)
    mixed_grade = FactoryBot.create(:grade,
      gender_type: "Mixed",
      min_participants: 2,
      max_participants: 2,
      min_males: 1,
      min_females: 1)
    open_grade = FactoryBot.create(:grade,
      gender_type: "Open",
      min_participants: 1,
      max_participants: 1,
      min_males: 0,
      min_females: 0)
 
    mens_entry_with_participants = FactoryBot.create(:sport_entry, 
      group: @group,
      grade: mens_grade)
    mens_entry_with_participants.participants << participant1
    mens_entry_with_participants.save

    mens_entry_with_no_participants = FactoryBot.create(:sport_entry, 
      group: @group,
      grade: mens_grade)

    ladies_entry = FactoryBot.create(:sport_entry, 
      group: @group,
      grade: ladies_grade)
                      
    mixed_entry_with_two_participants = FactoryBot.create(:sport_entry, 
      group: @group,
      grade: mixed_grade)
    mixed_entry_with_two_participants.participants << participant1
    mixed_entry_with_two_participants.participants << participant2
    mixed_entry_with_two_participants.save

    mixed_entry_with_one_male = FactoryBot.create(:sport_entry, 
      group: @group,
      grade: mixed_grade)
    mixed_entry_with_one_male.participants << participant1
    mixed_entry_with_one_male.save

    open_entry = FactoryBot.create(:sport_entry, 
      group: @group,
      grade: open_grade)

    #mens entry with enough males
    assert !@group.entries_requiring_males.include?(mens_entry_with_participants)

    #mens entry with no males
    assert @group.entries_requiring_males.include?(mens_entry_with_no_participants)

    #mixed entry with enough males
    assert !@group.entries_requiring_males.include?(mixed_entry_with_two_participants)

    #mixed entry with one male
    assert !@group.entries_requiring_males.include?(mixed_entry_with_one_male)

    #open entry
    assert !@group.entries_requiring_males.include?(open_entry)

    #ladies entry
    assert !@group.entries_requiring_males.include?(ladies_entry)

    #another group won't see my entries
    assert !other_group.entries_requiring_males.include?(mens_entry_with_no_participants)
  end

  test "should list all entries requiring females" do
    other_group = FactoryBot.create(:group)
    participant1 = FactoryBot.create(:participant, group: @group, gender: "M")
    participant2 = FactoryBot.create(:participant, group: @group, gender: "F")
    mens_grade = FactoryBot.create(:grade,
      gender_type: "Mens",
      min_participants: 1,
      max_participants: 1,
      min_males: 1)
    ladies_grade = FactoryBot.create(:grade,
      gender_type: "Ladies",
      min_participants: 1,
      max_participants: 1,
      min_females: 1)
    mixed_grade = FactoryBot.create(:grade,
      gender_type: "Mixed",
      min_participants: 2,
      max_participants: 2,
      min_males: 1,
      min_females: 1)
    open_grade = FactoryBot.create(:grade,
      gender_type: "Open",
      min_participants: 1,
      max_participants: 1,
      min_males: 0,
      min_females: 0)
 
    ladies_entry_with_participants = FactoryBot.create(:sport_entry, 
      group: @group,
      grade: ladies_grade)
    ladies_entry_with_participants.participants << participant2
    ladies_entry_with_participants.save

    ladies_entry_with_no_participants = FactoryBot.create(:sport_entry, 
      group: @group,
      grade: ladies_grade)

    mens_entry = FactoryBot.create(:sport_entry, 
      group: @group,
      grade: mens_grade)
                      
    mixed_entry_with_two_participants = FactoryBot.create(:sport_entry, 
      group: @group,
      grade: mixed_grade)
    mixed_entry_with_two_participants.participants << participant1
    mixed_entry_with_two_participants.participants << participant2
    mixed_entry_with_two_participants.save

    mixed_entry_with_one_female = FactoryBot.create(:sport_entry, 
      group: @group,
      grade: mixed_grade)
    mixed_entry_with_one_female.participants << participant2
    mixed_entry_with_one_female.save

    open_entry = FactoryBot.create(:sport_entry, 
      group: @group,
      grade: open_grade)

    #ladies entry with enough females
    assert !@group.entries_requiring_females.include?(ladies_entry_with_participants)

    #mens entry with no females
    assert @group.entries_requiring_females.include?(ladies_entry_with_no_participants)

    #mixed entry with enough males
    assert !@group.entries_requiring_females.include?(mixed_entry_with_two_participants)

    #mixed entry with one male
    assert !@group.entries_requiring_females.include?(mixed_entry_with_one_female)

    #open entry
    assert !@group.entries_requiring_females.include?(open_entry)

    #ladies entry
    assert !@group.entries_requiring_females.include?(mens_entry)

    #another group won't see my entries
    assert !other_group.entries_requiring_females.include?(ladies_entry_with_no_participants)
  end

  def test_group_sports_participants_for_grade
    male = FactoryBot.create(:participant, gender: "M", group: @group)
    female = FactoryBot.create(:participant, gender: "F", group: @group)
    too_old = FactoryBot.create(:participant, age: 55, group: @group)
    too_young = FactoryBot.create(:participant, :under18, age: 5, group: @group)
    spectator = FactoryBot.create(:participant, spectator: true, group: @group)
    not_coming = FactoryBot.create(:participant, coming: false, group: @group)
    player = FactoryBot.create(:participant, group: @group)

    mens_grade = FactoryBot.create(:grade, gender_type: "Mens")
    ladies_grade = FactoryBot.create(:grade, gender_type: "Ladies")
    mixed_grade = FactoryBot.create(:grade, gender_type: "Mixed")
    open_grade = FactoryBot.create(:grade, gender_type: "Open")
    under_18_grade = FactoryBot.create(:grade, max_age: 17)
    min_age_grade = FactoryBot.create(:grade, min_age: 16)
    playing_grade = FactoryBot.create(:grade)

    entry = FactoryBot.create(:sport_entry, grade: playing_grade, group: @group)
    entry.participants << player
    entry.save
    
    group = Group.find(@group.id)
    
    #satisfies all of the criteria (male grade)
    assert group.sports_participants_for_grade(mens_grade).
      include?(male)

    #satisfies all of the criteria (female grade)
    assert group.sports_participants_for_grade(ladies_grade).
      include?(female)
    
    #satisfies all of the criteria (mixed grade)
    assert group.sports_participants_for_grade(mixed_grade).
      include?(male)
    assert group.sports_participants_for_grade(mixed_grade).
      include?(female)
    
    #satisfies all of the criteria (open grade)
    assert group.sports_participants_for_grade(open_grade).
      include?(male)
    assert group.sports_participants_for_grade(open_grade).
      include?(female)
    
    #already playing this sport
    assert !group.sports_participants_for_grade(playing_grade).
      include?(player)
    
    #wrong sex (male grade)
    assert !group.sports_participants_for_grade(mens_grade).
      include?(female)
    
    #wrong sex (female grade)
    assert !group.sports_participants_for_grade(ladies_grade).
      include?(male)
    
    #too old
    assert !group.sports_participants_for_grade(under_18_grade).
      include?(too_old)
    
    #too young
    assert !group.sports_participants_for_grade(min_age_grade).
      include?(too_young)
    
    #spectator
    assert !group.sports_participants_for_grade(mens_grade).
      include?(spectator)
    
    #not coming
    assert !group.sports_participants_for_grade(mens_grade).
      include?(not_coming)
  end

  def test_group_grades_available
    open_team_grade = FactoryBot.create(:grade, 
                              status: "Open", 
                              grade_type: "Team")
    open_indiv_grade = FactoryBot.create(:grade, 
                               status: "Open", 
                               grade_type: "Singles")

    used_team_grade = FactoryBot.create(:grade, 
                              grade_type: "Team",
                              sport: FactoryBot.create(:sport, max_team_entries_group: 1))
    used_indiv_grade = FactoryBot.create(:grade, 
                               grade_type: "Singles",
                               sport: FactoryBot.create(:sport, max_indiv_entries_group: 1))
    FactoryBot.create(:sport_entry, grade: used_team_grade, group: @group)
    FactoryBot.create(:sport_entry, grade: used_indiv_grade, group: @group)
    
    closed_team_grade = FactoryBot.create(:grade, 
                                status: "Closed", 
                                grade_type: "Team",
                                entry_limit: 1)
    closed_indiv_grade = FactoryBot.create(:grade, 
                                 status: "Closed", 
                                 grade_type: "Singles",
                                 entry_limit: 1)
    FactoryBot.create(:sport_entry, grade: closed_team_grade)
    FactoryBot.create(:sport_entry, grade: closed_indiv_grade)
    
    #normal entries, still available
    assert @group.grades_available(false).include?(open_team_grade)
    assert @group.grades_available(false).include?(open_indiv_grade)
    
    #group has used up their allowance in this sport
    assert !@group.grades_available(false).include?(used_team_grade)
    assert !@group.grades_available(false).include?(used_indiv_grade)
    
    #grades are not accepting entries
    assert !@group.grades_available(false).include?(closed_team_grade)
    assert !@group.grades_available(false).include?(closed_indiv_grade)
    
    #override grades that are not accepting entries
    assert @group.grades_available(true).include?(closed_team_grade)
    assert @group.grades_available(true).include?(closed_indiv_grade)
    
    #override doesn't help groups that have used their allowance
    assert !@group.grades_available(true).include?(used_team_grade)
    assert !@group.grades_available(true).include?(used_indiv_grade)
  end

  def test_group_sports_available
    open_sport = FactoryBot.create(:sport)
    FactoryBot.create(:grade, 
                   status: "Open", 
                   sport: open_sport)

    used_sport = FactoryBot.create(:sport, max_team_entries_group: 1)
    used_grade = FactoryBot.create(:grade, 
                         grade_type: "Team",
                         sport: used_sport)
    FactoryBot.create(:sport_entry, grade: used_grade, group: @group)
    
    closed_sport = FactoryBot.create(:sport)
    closed_grade = FactoryBot.create(:grade, 
                           status: "Closed", 
                           entry_limit: 1,
                           sport: closed_sport)
    FactoryBot.create(:sport_entry, grade: closed_grade)
    
    #normal entries, still available
    assert @group.sports_available(false).include?(open_sport)

    #group has used up their allowance in this sport
    assert !@group.sports_available(false).include?(used_sport)
    
    #sport with only grades are not accepting entries
    assert !@group.sports_available(false).include?(closed_sport)
    
    #override sports that are not accepting entries
    assert @group.sports_available(true).include?(closed_sport)
    
    #override doesn't help groups that have used their allowance
    assert !@group.sports_available(true).include?(used_sport)
  end

  test "should assign short name" do
    FactoryBot.create(:group, short_name: "Aaaargh")
    
    #Normal use - returns first word of name
    assert_equal "Aaaa", Group.assign_short_name("Aaaa Church of Christ")
    #First name is already taken - returns first and second words of name
    assert_equal "Aaaargh Church", Group.assign_short_name("Aaaargh Church of Christ")
    #First name is already taken and ther is no second name
    assert_equal "Aaaargh1", Group.assign_short_name("Aaaargh")
  end

  test "should assign abbreviation" do
    FactoryBot.create(:group, abbr: "BB")
    
    #Normal use - returns first letter of the first four words of name
    assert_equal "ACOC", Group.assign_abbr("Aaaa Church of Christ")
    #Abbreviation is already taken - returns the next available abbreviation
    assert_equal "BC", Group.assign_abbr("Baaargh Baa")
    #Short Abbreviation - Duplicates until long enough
    assert_equal "AA", Group.assign_abbr("Aaaargh")
    #Shorter AND a duplication - Duplicates as well as finding the next one
    assert_equal "BC", Group.assign_abbr("Baaargh")
  end

  test "should retrieve the default group" do
    group = FactoryBot.create(:group, abbr: "DFLT")
    
    assert_equal group, Group.default_group
  end

  test "should reset allocation bonus" do
    g = FactoryBot.create(:group, allocation_bonus: 99)
    g.reset_allocation_bonus!

    g.reload
    assert_equal 0, g.allocation_bonus
  end

  test "should increment allocation bonus" do
    g = FactoryBot.create(:group, allocation_bonus: 0)
    g.increment_allocation_bonus!

    g.reload
    assert_equal @setting.missed_out_sports_allocation_factor, g.allocation_bonus
  end

  test "should import groups from file" do
    file = fixture_file_upload('group.csv','application/csv')
    
    assert_difference('Group.count') do
      @result = Group.import(file, @user)
    end

    assert_equal 1, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 0, @result[:errors]
  end

  test "should update exiting groups from file" do
    group = FactoryBot.create(:group, abbr: 'CAF')
    file = fixture_file_upload('group.csv','application/csv')
    
    assert_no_difference('Group.count') do
      @result = Group.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 1, @result[:updates]
    assert_equal 0, @result[:errors]

    group.reload
    assert_equal "Caffeine", group.short_name
  end

  test "should not import groups with errors from file" do
    file = fixture_file_upload('invalid_group.csv','application/csv')
    
    assert_no_difference('Group.count') do
      @result = Group.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]
  end

  test "should not update groups with errors from file" do
    group = FactoryBot.create(:group, abbr: "CAF")
    file = fixture_file_upload('invalid_group.csv','application/csv')
    
    assert_no_difference('Group.count') do
      @result = Group.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]

    group.reload
    assert_not_equal "Invalid", group.status
  end

  # Tests for searchable concern
  test "should search groups for matching :abbr" do
    groups = Group.search(@group.abbr)

    assert_equal true, groups.include?(@group)
  end

  test "should return empty when no match on search groups" do
    groups = Group.search("ZZZZ")

    assert_equal true, groups.empty?
  end
end
