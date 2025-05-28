# == Schema Information
#
# Table name: volunteers
#
#  id                   :bigint           not null, primary key
#  cc_email             :string(100)
#  collected            :boolean          default(FALSE)
#  description          :string(100)      not null
#  details_confirmed    :boolean          default(FALSE)
#  email                :string(100)
#  email_strategy       :string(20)       default("As defined in type")
#  email_template       :string(20)       default("Default")
#  equipment_in         :string
#  equipment_out        :string
#  lock_version         :integer          default(0)
#  mobile_confirmed     :boolean          default(FALSE)
#  mobile_number        :string(20)
#  notes                :text
#  returned             :boolean          default(FALSE)
#  send_volunteer_email :boolean          default(FALSE)
#  t_shirt_size         :string(10)
#  updated_by           :bigint
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  participant_id       :bigint
#  session_id           :bigint
#  volunteer_type_id    :bigint
#
# Indexes
#
#  index_volunteers_on_participant_id     (participant_id)
#  index_volunteers_on_volunteer_type_id  (volunteer_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (volunteer_type_id => volunteer_types.id)
#
require "test_helper"

class VolunteerTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  def setup
    FactoryBot.create(:setting)
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @volunteer = FactoryBot.create(:volunteer)
    @section = FactoryBot.create(:section)
    @section_volunteer = FactoryBot.create(:volunteer)
    @section_volunteer.sections << @section
    @volunteer_with_session = FactoryBot.create(:volunteer,
      session: FactoryBot.create(:session))
    @group = FactoryBot.create(:group)
    FactoryBot.create(:mysyg_setting, group: @group)
    FactoryBot.create(:event_detail, group: @group)
  end

  def test_volunteer_venue_name
    #volunteer has a Section
    assert_equal @section_volunteer.sections.first.venue_name, @section_volunteer.venue_name
    
    #no coordinator requirement
    assert_equal "(not venue-specific)", @volunteer.venue_name
  end

  def test_volunteer_session_name
    #specific session
    assert_equal @volunteer_with_session.session.name, @volunteer_with_session.session_name
    
    #volunteer has a Section
    assert_equal @section_volunteer.sections.first.session_name, @section_volunteer.session_name
    
    #no coordinator requirement
    assert_equal "(not session-specific)", @volunteer.session_name
  end

  def test_volunteer_name
    #volunteer has a Section
    assert_equal @section_volunteer.sections.first.name, @section_volunteer.name
    
    #no coordinator requirement
    assert_equal @volunteer.description, @volunteer.name
  end

  def test_volunteer_sport_name
    #volunteer has a Section
    assert_equal @section_volunteer.sections.first.sport_name, @section_volunteer.sport_name
    
    #no coordinator requirement
    assert_equal @volunteer.description, @volunteer.sport_name
  end

  def test_volunteer_sport
    #volunteer has a Section
    assert_equal @section_volunteer.sections.first.sport, @section_volunteer.sport
    
    #no coordinator requirement
    assert_nil @volunteer.sport
  end

  def test_volunteer_t_shirt_required
    volunteer_with_t_shirt = FactoryBot.create(:volunteer, volunteer_type: FactoryBot.create(:volunteer_type, t_shirt: true))
    volunteer_without_t_shirt = FactoryBot.create(:volunteer, volunteer_type: FactoryBot.create(:volunteer_type, t_shirt: false))
    
    assert_equal true, volunteer_with_t_shirt.t_shirt
    assert_equal false, volunteer_without_t_shirt.t_shirt
  end
  
  test "participant name should come from participant" do
    assert_equal '', @volunteer.participant_name

    participant = FactoryBot.create(:participant, group: @group)
    volunteer = FactoryBot.create(:volunteer, participant: participant)
    
    assert_equal participant.name, volunteer.participant_name
  end

  test "should take group from participant" do
    assert_nil @volunteer.group

    participant = FactoryBot.create(:participant, group: @group)
    volunteer = FactoryBot.create(:volunteer, participant: participant)
    
    assert_equal participant.group, volunteer.group
  end

  test "email recipients should include volunteer email" do
    volunteer = FactoryBot.create(:volunteer, email: "fred@nurk.com")
    
    assert_equal "fred@nurk.com", volunteer.email_recipients
  end
  
  test "email recipients should include group email recipients when no volunteer email" do
    group = FactoryBot.create(:group)
    FactoryBot.create(:mysyg_setting, group: group)
    FactoryBot.create(:event_detail, group: group)
    user = FactoryBot.create(:user, :gc)
    group.users << user
    participant = FactoryBot.create(:participant, group: group)
    volunteer = FactoryBot.create(:volunteer, email: nil, participant: participant)
    
    assert_equal participant.email, volunteer.email_recipients
  end
  
  test "number of teams should be the total number of teams for this coordinator" do
    grade = FactoryBot.create(:grade)
    section = FactoryBot.create(:section, grade: grade)
    5.times { FactoryBot.create(:sport_entry, grade: grade, section: section) }
    participant = FactoryBot.create(:participant, group: @group)
    volunteer = FactoryBot.create(:volunteer, participant: participant)
    volunteer.sections << section
    
    assert_equal 5, volunteer.number_of_teams
  end
  
  test "number of teams should be nil when nothing associated" do
    participant = FactoryBot.create(:participant, group: @group)
    volunteer = FactoryBot.create(:volunteer, participant: participant)
    
    assert_nil volunteer.number_of_teams
  end
  
  test "mobile phone number should be the number of the volunteer if provided" do
    participant = FactoryBot.create(:participant, group: @group)
    volunteer = FactoryBot.create(:volunteer, participant: participant, mobile_number: "0444111222")
    
    assert_equal "(0444) 111-222", volunteer.mobile_phone_number
  end
  
  test "mobile phone number should be the number of the participant if provided" do
    participant = FactoryBot.create(:participant, group: @group, mobile_phone_number: "0444333444")
    volunteer = FactoryBot.create(:volunteer, participant: participant, mobile_number: nil)
    
    assert_equal "(0444) 333-444", volunteer.mobile_phone_number
  end
  
  test "mobile phone number should be nil if not on volunteer or participant" do
    participant = FactoryBot.create(:participant, group: @group, mobile_phone_number: nil)
    volunteer = FactoryBot.create(:volunteer, participant: participant, mobile_number: nil)
    
    assert_nil volunteer.mobile_phone_number
  end

  test "should list all saturday sport coordinators" do
    sat_arvo = FactoryBot.create(:session, name: "Saturday Afternoon")
    section = FactoryBot.create(:section, session: sat_arvo)
    vt = FactoryBot.create(:volunteer_type, name: 'Sport Coordinator')
    sc = FactoryBot.create(:volunteer, volunteer_type: vt)
    sc.sections << section

    assert Volunteer.sport_coords_saturday.include?(sc)
    assert !Volunteer.sport_coords_sunday.include?(sc)
  end

  test "should list all sunday sport coordinators" do
    sun_arvo = FactoryBot.create(:session, name: "Sunday Afternoon")
    section = FactoryBot.create(:section, session: sun_arvo)
    vt = FactoryBot.create(:volunteer_type, name: 'Sport Coordinator')
    sc = FactoryBot.create(:volunteer, volunteer_type: vt)
    sc.sections << section

    assert Volunteer.sport_coords_sunday.include?(sc)
    assert !Volunteer.sport_coords_saturday.include?(sc)
  end

  test "should list all sport volunteers" do
    vt = FactoryBot.create(:volunteer_type, sport_related: true)
    sc = FactoryBot.create(:volunteer, volunteer_type: vt)

    assert Volunteer.sport_volunteers.include?(sc)
  end

  test "should import volunteer from file" do
    FactoryBot.create(:volunteer_type, database_code: "SPTC")
    file = fixture_file_upload('volunteer.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    
    assert_difference('Volunteer.count') do
      @result = Volunteer.import_excel(file, @user)
    end

    assert_equal 1, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 0, @result[:errors]
  end

  test "should update exiting volunteer from file" do
    FactoryBot.create(:volunteer_type, database_code: "SPTC")
    volunteer = FactoryBot.create(:volunteer, id: 123456, description: "Child Minding")
    file = fixture_file_upload('volunteer.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    
    assert_no_difference('Volunteer.count') do
      @result = Volunteer.import_excel(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 1, @result[:updates]
    assert_equal 0, @result[:errors]

    volunteer.reload
    assert_equal "Kitten Wrangling", volunteer.description
  end

  test "should not import volunteers with errors from file" do
    FactoryBot.create(:volunteer_type, database_code: "SPTC")
    file = fixture_file_upload('invalid_volunteer.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    
    assert_no_difference('Volunteer.count') do
      @result = Volunteer.import_excel(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]
  end

  test "should not update volunteers with errors from file" do
    FactoryBot.create(:volunteer_type, database_code: "SPTC")
    volunteer = FactoryBot.create(:volunteer, id: 123456, t_shirt_size: "M")
    file = fixture_file_upload('invalid_volunteer.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    
    assert_no_difference('Volunteer.count') do
      @result = Volunteer.import_excel(file, @user)
    end

    assert_equal 0, @result[:creates]
    assert_equal 0, @result[:updates]
    assert_equal 1, @result[:errors]

    volunteer.reload
    assert_not_equal "BIG", volunteer.t_shirt_size
  end

  test "should update participant sport coord flag when signs up" do
    sc = FactoryBot.create(:volunteer_type, :sport_coord)
    volunteer = FactoryBot.create(:volunteer, volunteer_type: sc)
    participant = FactoryBot.create(:participant, 
      group: @group, 
      sport_coord: false)

    volunteer.participant_id = participant.id
    volunteer.save

    participant.reload
    assert_equal true, participant.sport_coord
  end

  test "should update participant sport coord flag when releases" do
    participant = FactoryBot.create(:participant, 
      group: @group, 
      sport_coord: true)
    sc = FactoryBot.create(:volunteer_type, :sport_coord)
    volunteer = FactoryBot.create(:volunteer, 
      volunteer_type: sc,
      participant: participant)

    volunteer.participant_id = nil
    volunteer.save

    participant.reload
    assert_equal false, participant.sport_coord
  end

  test "should update participant sport coord flag when volunteer destroyed" do
    participant = FactoryBot.create(:participant, 
      group: @group, 
      sport_coord: true)
    sc = FactoryBot.create(:volunteer_type, :sport_coord)
    volunteer = FactoryBot.create(:volunteer, 
      volunteer_type: sc,
      participant: participant)

    volunteer.destroy

    participant.reload
    assert_equal false, participant.sport_coord
  end
end
