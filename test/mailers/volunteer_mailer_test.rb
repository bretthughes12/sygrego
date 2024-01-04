require "test_helper"

class VolunteerMailerTest < ActionMailer::TestCase
    tests VolunteerMailer
  
    def setup
      @admin_role = FactoryBot.create(:role, name: 'admin')
      @user = FactoryBot.create(:user)
      @setting = FactoryBot.create(:setting)
      @sport_coord = FactoryBot.create(:volunteer)
    end
    
    def test_sport_coordinator_email
      group = FactoryBot.create(:group)
      FactoryBot.create(:event_detail, group: group)
      section = FactoryBot.create(:section)
      participant = FactoryBot.create(:participant, group: group)
      volunteer = FactoryBot.create(:volunteer, participant: participant)
      volunteer.sections << section
      
      email = VolunteerMailer.welcome(volunteer)
      
      assert_match /Welcome Sports Coordinators/, email.subject  
      assert_equal volunteer.email_recipients, email.to[0]
      assert_match /Hi SYG sports co-ordinator/, email.parts[0].body.to_s
    end
  end
