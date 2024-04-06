# == Schema Information
#
# Table name: participants
#
#  id                     :bigint           not null, primary key
#  address                :string(200)
#  age                    :integer          default(30), not null
#  allergies              :string(255)
#  amount_paid            :decimal(8, 2)    default(0.0)
#  booking_nbr            :string(10)
#  camping_preferences    :string(100)
#  coming                 :boolean          default(TRUE)
#  coming_friday          :boolean          default(TRUE)
#  coming_monday          :boolean          default(TRUE)
#  coming_saturday        :boolean          default(TRUE)
#  coming_sunday          :boolean          default(TRUE)
#  database_rowid         :integer
#  date_of_birth          :date
#  dietary_requirements   :string(255)
#  dirty                  :boolean          default(FALSE)
#  driver                 :boolean          default(FALSE)
#  driver_signature       :boolean          default(FALSE)
#  driver_signature_date  :datetime
#  driving_to_syg         :boolean          default(FALSE)
#  early_bird             :boolean          default(FALSE)
#  email                  :string(100)
#  emergency_contact      :string(40)
#  emergency_email        :string(100)
#  emergency_phone_number :string(20)
#  emergency_relationship :string(20)
#  exported               :boolean          default(FALSE)
#  fee_when_withdrawn     :decimal(8, 2)    default(0.0)
#  first_name             :string(20)       not null
#  gender                 :string(1)        default("M"), not null
#  group_coord            :boolean          default(FALSE)
#  guest                  :boolean          default(FALSE)
#  helper                 :boolean          default(FALSE)
#  late_fee_charged       :boolean          default(FALSE)
#  licence_type           :string(15)
#  lock_version           :integer          default(0)
#  medical_info           :string(255)
#  medicare_expiry        :date
#  medicare_number        :string
#  medications            :string(255)
#  mobile_phone_number    :string(20)
#  number_plate           :string(10)
#  onsite                 :boolean          default(TRUE)
#  paid                   :boolean          default(FALSE)
#  phone_number           :string(20)
#  postcode               :integer
#  registration_nbr       :string(24)
#  rego_type              :string(10)       default("Full Time")
#  spectator              :boolean          default(FALSE)
#  sport_coord            :boolean          default(FALSE)
#  sport_notes            :string
#  status                 :string(20)       default("Accepted")
#  suburb                 :string(40)
#  surname                :string(20)       not null
#  updated_by             :bigint
#  vaccinated             :boolean          default(FALSE)
#  vaccination_document   :string(40)
#  vaccination_sighted_by :string(20)
#  withdrawn              :boolean          default(FALSE)
#  wwcc_number            :string
#  years_attended         :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  group_fee_category_id  :bigint
#  group_id               :bigint           default(0), not null
#  voucher_id             :bigint
#
# Indexes
#
#  index_participants_on_coming                               (coming)
#  index_participants_on_group_fee_category_id                (group_fee_category_id)
#  index_participants_on_group_id_and_surname_and_first_name  (group_id,surname,first_name) UNIQUE
#  index_participants_on_surname_and_first_name               (surname,first_name)
#  index_participants_on_voucher_id                           (voucher_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id)
#

require "test_helper"

class ParticipantTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def setup
    @user = FactoryBot.create(:user, :admin)
    @setting = FactoryBot.create(:setting)
    @group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, 
      group: @group)
    FactoryBot.create(:mysyg_setting, 
      group: @group,
      extra_fee_total: 30,
      extra_fee_per_day: 20)
    @participant = FactoryBot.create(:participant, group: @group)
  end

  test "should display driver fields" do
    assert_equal '', @participant.driver_sign
    assert_equal '', @participant.date_driver_signed

    @participant.driver_signature = true
    @participant.driver_signature_date = '1/2/2020'

    assert_equal '[electronic]', @participant.driver_sign
    assert_equal '01/02/2020', @participant.date_driver_signed
  end

  test "should validate years attended" do
    @setting.this_year = 2000
    @setting.save

    @participant.years_attended = 99

    assert !@participant.save
    assert @participant.errors[:years_attended].any?
  end

  def test_participant_fee_values
    full_participant = FactoryBot.create(:participant, group: @group)
    eleven_year_old_playing_sport = FactoryBot.create(:participant, :under18, group: @group, age: 11)
    spectator = FactoryBot.create(:participant, group: @group, spectator: true)
    primary_aged = FactoryBot.create(:participant, :under18, group: @group, age: 11, spectator: true)
    pre_schooler = FactoryBot.create(:participant, :under18, group: @group, age: 5)
    day_visitor_not_playing_sport = FactoryBot.create(:participant, group: @group, spectator: true, onsite: false, rego_type: "Part Time", coming_friday: false, coming_monday: false)
    day_visitor_playing_sport = FactoryBot.create(:participant, group: @group, onsite: false, rego_type: "Part Time", coming_friday: false, coming_sunday: false, coming_monday: false)
    early_day_visitor_playing_sport = FactoryBot.create(:participant, group: @group, onsite: false, rego_type: "Part Time", coming_friday: false, coming_sunday: false, coming_monday: false, early_bird: true)
    group_coordinator_playing_sport = FactoryBot.create(:participant, group: @group, group_coord: true)
    group_coordinator_not_playing_sport = FactoryBot.create(:participant, group: @group, group_coord: true, spectator: true)
    sport_coordinator_playing_sport = FactoryBot.create(:participant, group: @group, sport_coord: true)
    sport_coordinator_not_playing_sport = FactoryBot.create(:participant, group: @group, sport_coord: true, spectator: true)
    guest_playing_sport = FactoryBot.create(:participant, group: @group, guest: true)
    guest_not_playing_sport = FactoryBot.create(:participant, group: @group, guest: true, spectator: true)
    free_voucher = FactoryBot.create(:voucher, voucher_type: "Set", adjustment: 0)
    band_member = FactoryBot.create(:participant, group: @group, voucher: free_voucher)
    offsite_band_member = FactoryBot.create(:participant, 
      group: @group, 
      onsite: false,
      spectator: true,
      voucher: free_voucher)
    @setting.early_bird = true
    @setting.save
    early_participant = FactoryBot.create(:participant, group: @group, early_bird: true)
    early_day_visitor_not_playing_sport = FactoryBot.create(:participant, group: @group, spectator: true, onsite: false, rego_type: "Part Time", coming_friday: false, coming_monday: false, early_bird: true)

    assert_equal @setting.full_fee, full_participant.fee
    assert_equal @setting.full_fee, eleven_year_old_playing_sport.fee
    assert_equal 75, early_participant.fee
    assert_equal 45, spectator.fee
    assert_equal 15, primary_aged.fee
    assert_equal 0, pre_schooler.fee
    assert_equal 25, day_visitor_playing_sport.fee
    assert_equal 25, early_day_visitor_playing_sport.fee
    assert_equal 60, day_visitor_not_playing_sport.fee
    assert_equal 60, early_day_visitor_not_playing_sport.fee
    assert_equal 60, group_coordinator_playing_sport.fee
    assert_equal 35, group_coordinator_not_playing_sport.fee
    assert_equal 80, sport_coordinator_playing_sport.fee
    assert_equal 45, sport_coordinator_not_playing_sport.fee
    assert_equal 0, guest_playing_sport.fee
    assert_equal 0, guest_not_playing_sport.fee
    assert_equal 0, band_member.fee
    assert_equal 0, offsite_band_member.fee
  end

  test "should calculate the group extra fee" do
    full_participant = FactoryBot.create(:participant, 
      group: @group)
    day_visitor_playing_sport = FactoryBot.create(:participant, 
      group: @group, 
      onsite: false, 
      rego_type: "Part Time", 
      coming_friday: false, 
      coming_sunday: false, 
      coming_monday: false)

    assert_equal @group.extra_fee_total, full_participant.extra_fee
    assert_equal @group.extra_fee_per_day, day_visitor_playing_sport.extra_fee
  end

  def test_participant_category_values
    full_participant = FactoryBot.create(:participant, group: @group)
    spectator = FactoryBot.create(:participant, group: @group, spectator: true)
    primary_aged = FactoryBot.create(:participant, :under18, group: @group, age: 11, spectator: true)
    pre_schooler = FactoryBot.create(:participant, :under18, group: @group, age: 5)
    day_visitor_not_playing_sport = FactoryBot.create(:participant, group: @group, spectator: true, onsite: false)
    day_visitor_playing_sport = FactoryBot.create(:participant, group: @group, onsite: false)
    group_coordinator_playing_sport = FactoryBot.create(:participant, group: @group, group_coord: true)
    group_coordinator_not_playing_sport = FactoryBot.create(:participant, group: @group, group_coord: true, spectator: true)
    sport_coordinator_playing_sport = FactoryBot.create(:participant, group: @group, sport_coord: true)
    sport_coordinator_not_playing_sport = FactoryBot.create(:participant, group: @group, sport_coord: true, spectator: true)
    guest_playing_sport = FactoryBot.create(:participant, group: @group, guest: true)
    guest_not_playing_sport = FactoryBot.create(:participant, group: @group, guest: true, spectator: true)
    10.times do
      FactoryBot.create(:participant, group: full_participant.group)      
    end
    full_participant.group.reload
    team_helper = FactoryBot.create(:participant, spectator: true, helper: true, group: full_participant.group)
    offsite_team_helper = FactoryBot.create(:participant, spectator: true, helper: true, onsite: false, group: full_participant.group)
    @setting.early_bird = true
    @setting.save
    early_participant = FactoryBot.create(:participant, group: @group, early_bird: true)
    early_spectator = FactoryBot.create(:participant, group: @group, spectator: true, early_bird: true)
    early_day_visitor_playing_sport = FactoryBot.create(:participant, group: @group, onsite: false, early_bird: true)

    assert_equal "Child", primary_aged.category
    assert_equal "Sport Participant", full_participant.category
    assert_equal "Sport Participant (early bird)", early_participant.category
    assert_equal "SYG Sport Coordinator - Not playing sport", sport_coordinator_not_playing_sport.category
    assert_equal "Spectator", spectator.category
    assert_equal "Spectator (early bird)", early_spectator.category
    assert_equal "Ages 0-5", pre_schooler.category
    assert_equal "Sport Participant", day_visitor_playing_sport.category
    assert_equal "Sport Participant (early bird)", early_day_visitor_playing_sport.category
    assert_equal "Day Visitor", day_visitor_not_playing_sport.category
    assert_equal "Group Coordinator - Playing sport", group_coordinator_playing_sport.category
    assert_equal "Group Coordinator - Not playing sport", group_coordinator_not_playing_sport.category
    assert_equal "SYG Sport Coordinator - Playing sport", sport_coordinator_playing_sport.category
    assert_equal "SYG Guest - Playing sport", guest_playing_sport.category
    assert_equal "SYG Guest - Not playing sport", guest_not_playing_sport.category
    assert_equal "Team Helper", team_helper.category
    assert_equal "Team Helper - Not staying onsite", offsite_team_helper.category
  end

  def test_participant_can_play_sport
    player = FactoryBot.create(:participant, group: @group)

    #OK
    sport = FactoryBot.create(:sport)
    assert player.can_play_sport(sport)

    #already playing sport
    entry = FactoryBot.create(:sport_entry)
    entry.participants << player
    entry.save
    
    assert !player.can_play_sport(entry.sport)
    
    #playing sport, but allowed to play more times
    sport_that_can_be_played_more_than_once = FactoryBot.create(:sport, max_entries_indiv: 2)
    entry = FactoryBot.create(:sport_entry, 
                    grade: FactoryBot.create(:grade, 
                                            sport: sport_that_can_be_played_more_than_once))
    entry.participants << player
    entry.save
    
    assert player.can_play_sport(sport_that_can_be_played_more_than_once)
  end

  test "should include group name with name" do
    name = @participant.name + ' (' + @participant.group.short_name + ')'
    assert_equal name, @participant.name_with_group_name

    @participant.group = nil
    assert_equal @participant.name, @participant.name_with_group_name
  end

  test "should use sport entries for sports in session" do
    participant = FactoryBot.create(:participant, group: @group)
    entry = FactoryBot.create(:sport_entry, group: participant.group)
    entry.participants << participant
    
    assert participant.sports_in_session(entry.session_name).include?(entry.sport.name)
  end

  test "should use volunteers for sports in session" do
    participant = FactoryBot.create(:participant, group: @group)
    section = FactoryBot.create(:section)
    sc_type = FactoryBot.create(:volunteer_type, :sport_coord)
    volunteer = FactoryBot.create(:volunteer, 
      volunteer_type: sc_type,
      participant: participant)
    volunteer.sections << section
    
    assert participant.sports_in_session(section.session_name).include?(section.sport.name)
  end

  test "available sport entries should include entries participant can enter" do
    participant = FactoryBot.create(:participant, group: @group)
    entry = FactoryBot.create(:sport_entry, group: participant.group)
    participant.stubs(:can_play_sport).returns(true)
    SportEntry.any_instance.stubs(:can_take_participants?).returns(true)
    SportEntry.any_instance.stubs(:eligible_to_participate?).with(participant).returns(true)
    
    assert participant.available_sport_entries.include?(entry)
  end
  
  test "available sport entries should not include entries in sports that participants cannot play" do
    participant = FactoryBot.create(:participant, group: @group)
    entry = FactoryBot.create(:sport_entry, group: participant.group)
    participant.stubs(:can_play_sport).returns(false)
    SportEntry.any_instance.stubs(:can_take_participants?).returns(true)
    SportEntry.any_instance.stubs(:eligible_to_participate?).with(participant).returns(true)
    
    assert !participant.available_sport_entries.include?(entry)
  end
  
  test "available sport entries should not include entries that cannot take participants" do
    participant = FactoryBot.create(:participant, group: @group)
    entry = FactoryBot.create(:sport_entry, group: participant.group)
    participant.stubs(:can_play_sport).returns(true)
    SportEntry.any_instance.stubs(:can_take_participants?).returns(false)
    SportEntry.any_instance.stubs(:eligible_to_participate?).with(participant).returns(true)
    
    assert !participant.available_sport_entries.include?(entry)
  end
  
  test "available sport entries should not include entries for which participant is ineligible" do
    participant = FactoryBot.create(:participant, group: @group)
    entry = FactoryBot.create(:sport_entry, group: participant.group)
    participant.stubs(:can_play_sport).returns(true)
    SportEntry.any_instance.stubs(:can_take_participants?).returns(true)
    SportEntry.any_instance.stubs(:eligible_to_participate?).with(participant).returns(false)
    
    assert !participant.available_sport_entries.include?(entry)
  end
  
  test "available sport grades should include grades participant can enter" do
    participant = FactoryBot.create(:participant, group: @group)
    grade = FactoryBot.create(:grade)
    participant.stubs(:can_play_sport).returns(true)
    Grade.any_instance.stubs(:eligible_to_participate?).with(participant).returns(true)
    
    assert participant.available_grades.include?(grade)
  end
  
  test "available sport grades should not include grades in sports that participants cannot play" do
    participant = FactoryBot.create(:participant, group: @group)
    grade = FactoryBot.create(:grade)
    participant.stubs(:can_play_sport).returns(false)
    Grade.any_instance.stubs(:eligible_to_participate?).with(participant).returns(true)
    
    assert !participant.available_grades.include?(grade)
  end
  
  test "available sport grades should not include grades for which participant is ineligible" do
    participant = FactoryBot.create(:participant, group: @group)
    grade = FactoryBot.create(:grade)
    participant.stubs(:can_play_sport).returns(true)
    Grade.any_instance.stubs(:eligible_to_participate?).with(participant).returns(false)
    
    assert !participant.available_grades.include?(grade)
  end

  test "available sport sections should include sections participant can enter" do
    participant = FactoryBot.create(:participant, group: @group)
    grade = FactoryBot.create(:grade)
    section = FactoryBot.create(:section, grade: grade)
    participant.stubs(:can_play_sport).returns(true)
    Grade.any_instance.stubs(:eligible_to_participate?).with(participant).returns(true)
    
    assert participant.available_sections.include?(section)
  end
  
  test "available sport sections should not include sections in sports that participants cannot play" do
    participant = FactoryBot.create(:participant, group: @group)
    grade = FactoryBot.create(:grade)
    section = FactoryBot.create(:section, grade: grade)
    participant.stubs(:can_play_sport).returns(false)
    Grade.any_instance.stubs(:eligible_to_participate?).with(participant).returns(true)
    
    assert !participant.available_sections.include?(section)
  end
  
  test "available sport sections should not include sections for which participant is ineligible" do
    participant = FactoryBot.create(:participant, group: @group)
    grade = FactoryBot.create(:grade)
    section = FactoryBot.create(:section, grade: grade)
    participant.stubs(:can_play_sport).returns(true)
    Grade.any_instance.stubs(:eligible_to_participate?).with(participant).returns(false)
    
    assert !participant.available_sections.include?(section)
  end

  test "grades i can join should include grades participant can enter" do
    participant = FactoryBot.create(:participant, group: @group)
    grade = FactoryBot.create(:grade)
    FactoryBot.create(:sport_entry, grade: grade, group: @group)
    participant.stubs(:can_play_sport).returns(true)
    participant.stubs(:can_play_grade).returns(true)
    Grade.any_instance.stubs(:eligible_to_participate?).with(participant).returns(true)
    
    assert participant.group_grades_i_can_join.include?(grade)
  end
  
  test "grades i can join should not include grades in sports that participants cannot play" do
    participant = FactoryBot.create(:participant, group: @group)
    grade = FactoryBot.create(:grade)
    FactoryBot.create(:sport_entry, grade: grade, group: @group)
    participant.stubs(:can_play_sport).returns(false)
    participant.stubs(:can_play_grade).returns(true)
    Grade.any_instance.stubs(:eligible_to_participate?).with(participant).returns(true)
    
    assert !participant.group_grades_i_can_join.include?(grade)
  end
  
  test "grades i can join should not include grades that participants cannot play" do
    participant = FactoryBot.create(:participant, group: @group)
    grade = FactoryBot.create(:grade)
    FactoryBot.create(:sport_entry, grade: grade, group: @group)
    participant.stubs(:can_play_sport).returns(true)
    participant.stubs(:can_play_grade).returns(false)
    Grade.any_instance.stubs(:eligible_to_participate?).with(participant).returns(true)
    
    assert !participant.group_grades_i_can_join.include?(grade)
  end
  
  test "grades i can join should not include grades for which participant is ineligible" do
    participant = FactoryBot.create(:participant, group: @group)
    grade = FactoryBot.create(:grade)
    FactoryBot.create(:sport_entry, grade: grade, group: @group)
    participant.stubs(:can_play_sport).returns(true)
    participant.stubs(:can_play_grade).returns(true)
    Grade.any_instance.stubs(:eligible_to_participate?).with(participant).returns(false)
    
    assert !participant.group_grades_i_can_join.include?(grade)
  end

  test "should show text for ticket email" do
    gc_role = FactoryBot.create(:role, "gc")
    gc1 = FactoryBot.create(:user)
    gc1.roles << gc_role
    @group.users << gc1

    # @group.ticket_preference = 'Send to GC'
    assert_equal gc1.email, @participant.ticket_email

    @group.ticket_preference = 'Send to Participant'
    @group.save
    assert_equal @participant.email, @participant.ticket_email

    @group.ticket_preference = 'Send to Ticket Email'
    # @group.ticket_email = nil
    @group.save
    assert_equal gc1.email, @participant.ticket_email

    @group.ticket_preference = 'Send to Ticket Email'
    @group.ticket_email = 'send@to-me.com'
    @group.save
    assert_equal 'send@to-me.com', @participant.ticket_email
  end

  test "should show text for ticket type" do
    # @participant.coming_* = true
    assert_equal 'All Days', @participant.ticket_type

    @participant.coming_friday = false
    @participant.coming_monday = false
    assert_equal 'SAT / SUN', @participant.ticket_type

    @participant.coming_friday = true
    @participant.coming_saturday = false
    @participant.coming_sunday = false
    @participant.coming_monday = true
    assert_equal 'FRI / MON', @participant.ticket_type

    @participant.coming_friday = false
    @participant.coming_monday = false
    assert_equal 'NONE', @participant.ticket_type
  end
  
  test "should show WWCC text" do
    @participant.wwcc_number = "A12345-BC"
    assert_equal "WWCC: A12345-BC", @participant.wwcc_text

    @participant.age = 17
    assert_equal "WWCC: A12345-BC", @participant.wwcc_text

    @participant.wwcc_number = nil
    assert_equal "WWCC: not required", @participant.wwcc_text
  end
  
  test "should import participants from file" do
    FactoryBot.create(:group, abbr: "CAF")
    file = fixture_file_upload('participant.csv','application/csv')
    
    assert_difference('Participant.count') do
      @result = Participant.import(file, @user)
    end

    assert_equal 1, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 0, @result[:errors]
  end
  
  test "should import alternate participants from file" do
    FactoryBot.create(:group, abbr: "CAF")
    file = fixture_file_upload('participant2.csv','application/csv')
    voucher = FactoryBot.create(:voucher,
      name: "VOUCHER",
      voucher_type: "Set",
      adjustment: 0.0)

    assert_difference('Participant.count') do
      @result = Participant.import(file, @user)
    end

    assert_equal 1, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 0, @result[:errors]
  end

  test "should assign participants to default group if group not found" do
    group = FactoryBot.create(:group, abbr: "DFLT")
    file = fixture_file_upload('participant.csv','application/csv')
    
    assert_difference('Participant.count') do
      @result = Participant.import(file, @user)
    end

    assert_equal 1, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 0, @result[:errors]

    group.reload
    assert_equal 1, group.participants.size
  end

  test "should update exiting participants from file" do
    group = FactoryBot.create(:group, abbr: "CAF")
    FactoryBot.create(:event_detail, group: group)
    participant = FactoryBot.create(:participant, 
      group: group,
      first_name: "Amos",
      surname: "Burton")
    file = fixture_file_upload('participant.csv','application/csv')
    
    assert_no_difference('Participant.count') do
      @result = Participant.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 1, @result[:updates]
    assert_equal 0, @result[:errors]

    participant.reload
    assert_equal 35, participant.age
  end

  test "should update exiting participants from file and assign voucher" do
    group = FactoryBot.create(:group, abbr: "CAF")
    FactoryBot.create(:event_detail, group: group)
    participant = FactoryBot.create(:participant, 
      group: group,
      first_name: "Amos",
      surname: "Burton")
    voucher = FactoryBot.create(:voucher,
      name: "VOUCHER",
      voucher_type: "Set",
      adjustment: 0.0)
    file = fixture_file_upload('participant2.csv','application/csv')
    
    assert_no_difference('Participant.count') do
      @result = Participant.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 1, @result[:updates]
    assert_equal 0, @result[:errors]

    participant.reload
    assert_equal 35, participant.age
    assert_equal 0, participant.fee
  end

  test "should not import participants with errors from file" do
    FactoryBot.create(:group, abbr: "CAF")
    file = fixture_file_upload('invalid_participant.csv','application/csv')
    
    assert_no_difference('Participant.count') do
      @result = Participant.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]
  end

  test "should not update participants with errors from file" do
    group = FactoryBot.create(:group, abbr: "CAF")
    FactoryBot.create(:event_detail, group: group)
    participant = FactoryBot.create(:participant, 
      group: group,
      first_name: "Amos",
      surname: "Burton")
    file = fixture_file_upload('invalid_participant.csv','application/csv')
    
    assert_no_difference('Participant.count') do
      @result = Participant.import(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]

    participant.reload
    assert_not_equal "X", participant.gender
  end

  test "should import GC participants from file" do
    group = FactoryBot.create(:group)
    file = fixture_file_upload('participant_gc.csv','application/csv')
    
    assert_difference('Participant.count') do
      @result = Participant.import_gc(file, group, @user)
    end

    assert_equal 1, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 0, @result[:errors]
  end

  test "should import alternate GC participants from file" do
    group = FactoryBot.create(:group)
    file = fixture_file_upload('participant2_gc.csv','application/csv')
    
    assert_difference('Participant.count') do
      @result = Participant.import_gc(file, group, @user)
    end

    assert_equal 1, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 0, @result[:errors]
  end

  test "should update exiting GC participants from file" do
    group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: group)
    participant = FactoryBot.create(:participant, 
      group: group,
      first_name: "Amos",
      surname: "Burton")
    file = fixture_file_upload('participant_gc.csv','application/csv')
    
    assert_no_difference('Participant.count') do
      @result = Participant.import_gc(file, group, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 1, @result[:updates]
    assert_equal 0, @result[:errors]

    participant.reload
    assert_equal 35, participant.age
  end

  test "should not import GC participants with errors from file" do
    group = FactoryBot.create(:group)
    file = fixture_file_upload('invalid_participant_gc.csv','application/csv')
    
    assert_no_difference('Participant.count') do
      @result = Participant.import_gc(file, group, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]
  end

  test "should not update GC participants with errors from file" do
    group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: group)
    participant = FactoryBot.create(:participant, 
      group: group,
      first_name: "Amos",
      surname: "Burton")
    file = fixture_file_upload('invalid_participant_gc.csv','application/csv')
    
    assert_no_difference('Participant.count') do
      @result = Participant.import_gc(file, group, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]

    participant.reload
    assert_not_equal "X", participant.gender
  end

  test "should import day visitors from ticket file" do
    group = FactoryBot.create(:group, abbr: 'DAY')
    FactoryBot.create(:event_detail, group: group)
    file = fixture_file_upload('tickets.csv','application/csv')
    
    assert_difference('Participant.count', 1) do
      @result = Participant.import_ticket(file, @user)
    end

    assert_equal 1, @result[:day_visitors]
    assert_equal 1, @result[:misses]
    assert_equal 0, @result[:updates]
    assert_equal 0, @result[:errors]
  end

  test "should update existing day visitors from ticket file" do
    group = FactoryBot.create(:group, abbr: 'DAY')
    FactoryBot.create(:event_detail, group: group)
    participant = FactoryBot.create(:participant, 
      group: group,
      id: 1234)
    file = fixture_file_upload('tickets.csv','application/csv')
    
    assert_difference('Participant.count', 1) do
      @result = Participant.import_ticket(file, @user)
    end

    assert_equal 1, @result[:day_visitors]
    assert_equal 0, @result[:misses]
    assert_equal 1, @result[:updates]
    assert_equal 0, @result[:errors]

    participant.reload
    assert_equal 'zY_HBUXAHke9GlJIttEuaA', participant.registration_nbr
  end

  test "should not import invalid day visitors from ticket file" do
    group = FactoryBot.create(:group, abbr: 'DAY')
    FactoryBot.create(:event_detail, group: group)
    file = fixture_file_upload('invalid_tickets.csv','application/csv')
    
    assert_no_difference('Participant.count') do
      @result = Participant.import_ticket(file, @user)
    end

    assert_equal 0, @result[:day_visitors]
    assert_equal 0, @result[:misses]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]
  end

  test "should import day visitors from excel ticket file" do
    group = FactoryBot.create(:group, abbr: 'DAY')
    FactoryBot.create(:event_detail, group: group)
    file = fixture_file_upload('tickets.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    
    assert_difference('Participant.count', 1) do
      @result = Participant.import_ticket_excel(file, @user)
    end

    assert_equal 1, @result[:day_visitors]
    assert_equal 1, @result[:misses]
    assert_equal 0, @result[:updates]
    assert_equal 0, @result[:errors]
  end

  test "should update existing day visitors from excel ticket file" do
    group = FactoryBot.create(:group, abbr: 'DAY')
    FactoryBot.create(:event_detail, group: group)
    participant = FactoryBot.create(:participant, 
      group: group,
      id: 1234)
    file = fixture_file_upload('tickets.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    
    assert_difference('Participant.count', 1) do
      @result = Participant.import_ticket_excel(file, @user)
    end

    assert_equal 1, @result[:day_visitors]
    assert_equal 0, @result[:misses]
    assert_equal 1, @result[:updates]
    assert_equal 0, @result[:errors]

    participant.reload
    assert_equal 'zY_HBUXAHke9GlJIttEuaA', participant.registration_nbr
  end

  test "should not import invalid day visitors from excel ticket file" do
    group = FactoryBot.create(:group, abbr: 'DAY')
    FactoryBot.create(:event_detail, group: group)
    file = fixture_file_upload('invalid_tickets.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    
    assert_no_difference('Participant.count') do
      @result = Participant.import_ticket_excel(file, @user)
    end

    assert_equal 0, @result[:day_visitors]
    assert_equal 0, @result[:misses]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]
  end

  test "should force participant to offsite when group is offsite" do
    group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, 
      group: group,
      onsite: false)
    participant = FactoryBot.create(:participant, 
      group: group,
      onsite: true)

    participant.reload
    assert_equal false, participant.onsite
  end

  test "should remove participant from sport entries when changed to not coming" do
    group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, 
      group: group)
    participant = FactoryBot.create(:participant, 
      group: group,
      coming: true)
    entry = FactoryBot.create(:sport_entry,
      group: group)
    entry.participants << participant
    entry.captaincy = participant
    entry.save

    participant.coming = false
    participant.save

    entry.reload

    assert_equal 0, entry.participants.size
    assert_nil entry.captaincy
  end

  test "should remove participant from sport entries when changed to spectator" do
    group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, 
      group: group)
    participant = FactoryBot.create(:participant, 
      group: group,
      coming: true,
      spectator: false)
    entry = FactoryBot.create(:sport_entry,
      group: group)
    entry.participants << participant
    entry.captaincy = participant
    entry.save

    participant.spectator = true
    participant.save

    entry.reload

    assert_equal 0, entry.participants.size
    assert_nil entry.captaincy
  end

  test "should remove participant from volunteers when destroyed" do
    group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, 
      group: group)
    participant = FactoryBot.create(:participant, 
      group: group,
      coming: true,
      spectator: false)
    volunteer = FactoryBot.create(:volunteer,
      participant: participant,
      mobile_number: "0444444444",
      email: "ace@rimmer.com",
      t_shirt_size: "M")

    participant.destroy

    volunteer.reload

    assert_nil volunteer.participant
    assert_nil volunteer.mobile_number
    assert_nil volunteer.email
    assert_nil volunteer.t_shirt_size
  end

  def test_should_normalize_phone_number
    #local number
    assert_equal "(0#{APP_CONFIG[:state_area_code]}) 9555-1122", Participant.normalize_phone_number("95551122")
    assert_equal "(0#{APP_CONFIG[:state_area_code]}) 9555-1122", Participant.normalize_phone_number("9555-1122")
    assert_equal "(03) 9555-1122", Participant.normalize_phone_number("03-9555-1122")
    assert_equal "(03) 9555-1122", Participant.normalize_phone_number("(03) 9555-1122")
    #mobile number
    assert_equal "(0444) 555-666", Participant.normalize_phone_number("0444555666")
    assert_equal "(0444) 555-666", Participant.normalize_phone_number("(0444) 555666")
    assert_equal "(0444) 555-666", Participant.normalize_phone_number("0444-555-666")
    assert_equal "(0444) 555-666", Participant.normalize_phone_number("(0444) 555-666")
    #not recognised
    assert_equal "private", Participant.normalize_phone_number("private")
    assert_equal "04445556667", Participant.normalize_phone_number("04445556667")
    #empty
    assert_equal "", Participant.normalize_phone_number("")
  end

  def test_should_normalize_medical_info
    #normal
    assert_equal "brain damage", Participant.normalize_medical_info("brain damage")
    #nil
    assert_nil Participant.normalize_medical_info("none")
    assert_nil Participant.normalize_medical_info("None")
    assert_nil Participant.normalize_medical_info("N/A")
    assert_nil Participant.normalize_medical_info("n/a")
    assert_nil Participant.normalize_medical_info("-")
    assert_nil Participant.normalize_medical_info("nil")
    assert_nil Participant.normalize_medical_info("")
  end

  def test_should_normalize_suburb
    #normal case
    assert_equal "Cheltenham", Participant.normalize_suburb("cheltenham")
    #variations on North
    assert_equal "Moe North", Participant.normalize_suburb("moe n")
    assert_equal "Moe North", Participant.normalize_suburb("moe nth")
    assert_equal "Moe North", Participant.normalize_suburb("moe n.")
    assert_equal "Moe North", Participant.normalize_suburb("moe nth.")
    assert_equal "North Moe", Participant.normalize_suburb("n moe")
    assert_equal "North", Participant.normalize_suburb("n")
    #variations on South
    assert_equal "Moe South", Participant.normalize_suburb("moe s")
    assert_equal "Moe South", Participant.normalize_suburb("moe sth")
    assert_equal "Moe South", Participant.normalize_suburb("moe s.")
    assert_equal "Moe South", Participant.normalize_suburb("moe sth.")
    assert_equal "South Moe", Participant.normalize_suburb("s moe")
    assert_equal "South", Participant.normalize_suburb("s")
    #variations on East
    assert_equal "Moe East", Participant.normalize_suburb("moe e")
    assert_equal "Moe East", Participant.normalize_suburb("moe e.")
    assert_equal "East Moe", Participant.normalize_suburb("e moe")
    assert_equal "East", Participant.normalize_suburb("e")
    #variations on West
    assert_equal "Moe West", Participant.normalize_suburb("moe w")
    assert_equal "Moe West", Participant.normalize_suburb("moe w.")
    assert_equal "West Moe", Participant.normalize_suburb("w moe")
    assert_equal "West", Participant.normalize_suburb("w")
    #empty input
    assert_equal "", Participant.normalize_suburb("")
  end

  def test_should_normalize_surname
    #normal case
    assert_equal "Smith", Participant.normalize_surname("smith")
    #a Macca
    assert_equal "McDonald", Participant.normalize_surname("mcdonald")
    #someone Irish
    assert_equal "O'Smythe", Participant.normalize_surname("o'smythe")
    #hyphenated name
    assert_equal "Bleedington-Smythe", Participant.normalize_surname("Bleedington-smythe")
    #two names
    assert_equal "Ablett Jnr", Participant.normalize_surname("Ablett jnr")
    #a little bit of everything
    assert_equal "O'McDonald-Smythe Jnr", Participant.normalize_surname("o'mcdonald-smythe jnr")
    #empty input
    assert_equal "", Participant.normalize_surname("")
  end

  def test_should_normalize_address
    #normal case
    assert_equal "33 Elliot St", Participant.normalize_address("33 elliot street")
    assert_equal "33 Elliot St", Participant.normalize_address("33 Elliot St")
    #road
    assert_equal "33 Elliot Rd", Participant.normalize_address("33 elliot road")
    #avenue
    assert_equal "33 Elliot Ave", Participant.normalize_address("33 elliot av")
    assert_equal "33 Elliot Ave", Participant.normalize_address("33 elliot avenue")
    #close
    assert_equal "33 Elliot Cl", Participant.normalize_address("33 elliot close")
    #boulevard
    assert_equal "33 Elliot Blvd", Participant.normalize_address("33 elliot Boulevard")
    #lane
    assert_equal "33 Elliot Ln", Participant.normalize_address("33 elliot Lane")
    #court
    assert_equal "33 Elliot Crt", Participant.normalize_address("33 elliot court")
    #grove
    assert_equal "33 Elliot Gve", Participant.normalize_address("33 elliot grove")
    assert_equal "33 Elliot Gve", Participant.normalize_address("33 elliot gr")
    #crescent
    assert_equal "33 Elliot Cres", Participant.normalize_address("33 elliot cresent")
    assert_equal "33 Elliot Cres", Participant.normalize_address("33 elliot crescent")
    #place
    assert_equal "33 Elliot Pl", Participant.normalize_address("33 elliot Place")
    #parade
    assert_equal "33 Elliot Pde", Participant.normalize_address("33 elliot parade")
    #drive
    assert_equal "33 Elliot Dve", Participant.normalize_address("33 elliot drive")
    assert_equal "33 Elliot Dve", Participant.normalize_address("33 elliot dr")
    assert_equal "33 Elliot Dve", Participant.normalize_address("33 elliot drv")
    #parade
    assert_equal "33 Elliot Tce", Participant.normalize_address("33 elliot terrace")
    #highway
    assert_equal "33 Elliot Hwy", Participant.normalize_address("33 elliot Highway")
    #square
    assert_equal "33 Elliot Sq", Participant.normalize_address("33 elliot square")
    #track
    assert_equal "33 Elliot Tk", Participant.normalize_address("33 elliot track")
    #p.o. box
    assert_equal "P.O. Box 33", Participant.normalize_address("po box 33")
    assert_equal "P.O. Box 33", Participant.normalize_address("p.o box 33")
    assert_equal "P.O. Box 33", Participant.normalize_address("p.o. box 33")
    #r.m.b. 
    assert_equal "R.M.B. 33", Participant.normalize_address("rmb 33")
    assert_equal "R.M.B. 33", Participant.normalize_address("r.m.b 33")
    assert_equal "R.M.B. 33", Participant.normalize_address("r.m.b. 33")
    #r.s.d. 
    assert_equal "R.S.D. 33", Participant.normalize_address("rsd 33")
    assert_equal "R.S.D. 33", Participant.normalize_address("r.s.d 33")
    assert_equal "R.S.D. 33", Participant.normalize_address("r.s.d. 33")
    #slash-hyphen-quote
    assert_equal "3/3 Elliot St", Participant.normalize_address('3/3 elliot street')
    assert_equal "'The Swamp Emmerson-Windchester Corner M/A/S/H", Participant.normalize_address("'the swamp' emmerson-windchester corner m/a/s/h")
    #empty input
    assert_equal "", Participant.normalize_address("")
  end
end
