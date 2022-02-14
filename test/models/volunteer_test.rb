# == Schema Information
#
# Table name: volunteers
#
#  id                :bigint           not null, primary key
#  collected         :boolean          default(FALSE)
#  description       :string(100)      not null
#  details_confirmed :boolean          default(FALSE)
#  email             :string(40)
#  equipment_in      :string
#  equipment_out     :string
#  lock_version      :integer          default(0)
#  mobile_confirmed  :boolean          default(FALSE)
#  mobile_number     :string(20)
#  notes             :text
#  returned          :boolean          default(FALSE)
#  t_shirt_size      :string(10)
#  updated_by        :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  participant_id    :bigint
#  section_id        :bigint
#  session_id        :bigint
#  volunteer_type_id :bigint
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
    @section_volunteer = FactoryBot.create(:volunteer,
      section: FactoryBot.create(:section))
    @volunteer_with_session = FactoryBot.create(:volunteer,
      session: FactoryBot.create(:session))
  end

  def test_volunteer_venue_name
    #volunteer has a Section
    assert_equal @section_volunteer.section.venue_name, @section_volunteer.venue_name
    
    #no coordinator requirement
    assert_equal "(not venue-specific)", @volunteer.venue_name
  end

  def test_volunteer_session_name
    #specific session
    assert_equal @volunteer_with_session.session.name, @volunteer_with_session.session_name
    
    #volunteer has a Section
    assert_equal @section_volunteer.section.session_name, @section_volunteer.session_name
    
    #no coordinator requirement
    assert_equal "(not session-specific)", @volunteer.session_name
  end

  def test_volunteer_name
    #volunteer has a Section
    assert_equal @section_volunteer.section.name, @section_volunteer.name
    
    #no coordinator requirement
    assert_equal @volunteer.description, @volunteer.name
  end

  def test_volunteer_sport_name
    #volunteer has a Section
    assert_equal @section_volunteer.section.sport_name, @section_volunteer.sport_name
    
    #no coordinator requirement
    assert_equal @volunteer.description, @volunteer.sport_name
  end

  def test_volunteer_t_shirt_required
    volunteer_with_t_shirt = FactoryBot.create(:volunteer, volunteer_type: FactoryBot.create(:volunteer_type, t_shirt: true))
    volunteer_without_t_shirt = FactoryBot.create(:volunteer, volunteer_type: FactoryBot.create(:volunteer_type, t_shirt: false))
    
    assert_equal true, volunteer_with_t_shirt.t_shirt
    assert_equal false, volunteer_without_t_shirt.t_shirt
  end
  
  test "email recipients should include volunteer email" do
    volunteer = FactoryBot.create(:volunteer, email: "fred@nurk.com")
    
    assert_equal "fred@nurk.com", volunteer.email_recipients
  end
  
  test "email recipients should include group email recipients when no volunteer email" do
    group = FactoryBot.create(:group)
    user = FactoryBot.create(:user, :gc)
    group.users << user
    participant = FactoryBot.create(:participant, group: group)
    volunteer = FactoryBot.create(:volunteer, email: nil, participant: participant)
    
    assert_equal [user.email], volunteer.email_recipients
  end
  
  test "number of teams should be the total number of teams for this coordinator" do
    grade = FactoryBot.create(:grade)
    section = FactoryBot.create(:section, grade: grade)
    5.times { FactoryBot.create(:sport_entry, grade: grade, section: section) }
    participant = FactoryBot.create(:participant)
    volunteer = FactoryBot.create(:volunteer, participant: participant, section: section)
    
    assert_equal 5, volunteer.number_of_teams
  end
  
  test "number of teams should be nil when nothing associated" do
    participant = FactoryBot.create(:participant)
    volunteer = FactoryBot.create(:volunteer, participant: participant, section: nil)
    
    assert_nil volunteer.number_of_teams
  end
  
  test "mobile phone number should be the number of the volunteer if provided" do
    participant = FactoryBot.create(:participant)
    volunteer = FactoryBot.create(:volunteer, participant: participant, mobile_number: "0444111222")
    
    assert_equal "(0444) 111-222", volunteer.mobile_phone_number
  end
  
  test "mobile phone number should be the number of the participant if provided" do
    participant = FactoryBot.create(:participant, mobile_phone_number: "0444333444")
    volunteer = FactoryBot.create(:volunteer, participant: participant, mobile_number: nil)
    
    assert_equal "(0444) 333-444", volunteer.mobile_phone_number
  end
  
  test "mobile phone number should be nil if not on volunteer or participant" do
    participant = FactoryBot.create(:participant, mobile_phone_number: nil)
    volunteer = FactoryBot.create(:volunteer, participant: participant, mobile_number: nil)
    
    assert_nil volunteer.mobile_phone_number
  end
end
