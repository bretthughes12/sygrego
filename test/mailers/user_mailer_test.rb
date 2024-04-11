require "test_helper"

class UserMailerTest < ActionMailer::TestCase
    tests UserMailer
  
    def setup
        @settings = FactoryBot.create(:setting)
        @admin_role = FactoryBot.create(:role, name: 'admin')
        @gc_role = FactoryBot.create(:role, name: 'gc', group_related: true)
        @church_rep_role = FactoryBot.create(:role, name: 'church_rep', group_related: true)
        @participant_role = FactoryBot.create(:role, name: 'participant', participant_related: true)
        FactoryBot.create(:user)
    end
    
    test "should send a welcome church rep email" do
      group = FactoryBot.create(:group, lock_version: 0)
      church_rep = FactoryBot.create(:user)
      church_rep.roles << @church_rep_role
      church_rep.groups << group
  
      email = UserMailer.welcome_church_rep(church_rep)
      
      assert_match /Welcome to the SYG Registrations website/, email.subject  
      assert_equal church_rep.email, email.to[0]
      assert_match /Thank you for registering/, email.parts[0].body.to_s
      assert_match /#{church_rep.email}/, email.parts[0].body.to_s
      assert_match /#{church_rep.name}/, email.parts[0].body.to_s
    end
    
    test "should send a gc nomination email" do
      group = FactoryBot.create(:group, lock_version: 0)
      gc = FactoryBot.create(:user)
      gc.roles << @gc_role
      gc.groups << group
      token = gc.get_reset_password_token

      church_rep = FactoryBot.create(:user)
      church_rep.roles.delete(@admin_role)
      church_rep.roles << @church_rep_role
      church_rep.groups << group

      email = UserMailer.gc_nomination(gc, group, church_rep, token)
      
      assert_match /SYG Group Coordinator Nomination/, email.subject  
      assert_equal gc.email, email.to[0]
      assert_match /You have been nominated/, email.parts[0].body.to_s
      assert_match /#{gc.email}/, email.parts[0].body.to_s
      assert_match /#{gc.name}/, email.parts[0].body.to_s
    end
    
    test "should send a gc approval email" do
      group = FactoryBot.create(:group, lock_version: 0)
      gc = FactoryBot.create(:user)
      gc.roles << @gc_role
      gc.groups << group

      email = UserMailer.gc_approval(gc)
      
      assert_match /Welcome Group Coordinator/, email.subject  
      assert_equal gc.email, email.to[0]
      assert_match /Your group has now been approved/, email.parts[0].body.to_s
      assert_match /#{gc.name}/, email.parts[0].body.to_s
    end
    
    test "should send a welcome participant email" do
      group = FactoryBot.create(:group, lock_version: 0)
      FactoryBot.create(:mysyg_setting, group: group)
      FactoryBot.create(:event_detail, group: group)
      participant = FactoryBot.create(:participant, group: group)
      user = FactoryBot.create(:user)
      user.roles << @participant_role
      participant.users << user
      participant.reload
  
      email = UserMailer.welcome_participant(user, participant)
      
      assert_match /Welcome to the SYG Registrations website/, email.subject  
      assert_equal user.email, email.to[0]
      assert_match /Thank you for registering/, email.parts[0].body.to_s
      assert_match /#{user.email}/, email.parts[0].body.to_s
      assert_match /#{user.name}/, email.parts[0].body.to_s
    end
    
    test "should send a reject participant email" do
      group = FactoryBot.create(:group, lock_version: 0)
      FactoryBot.create(:mysyg_setting, group: group)
      FactoryBot.create(:event_detail, group: group)
      participant = FactoryBot.create(:participant, group: group)
      user = FactoryBot.create(:user)
      user.roles << @participant_role
      participant.users << user
      participant.reload
  
      email = UserMailer.reject_participant(participant, group)
      
      assert_match /Participant rejected/, email.subject  
      assert_equal @settings.rego_email, email.to[0]
      assert_match /participant has just been rejected/, email.parts[0].body.to_s
      assert_match /#{participant.name}/, email.parts[0].body.to_s
      assert_match /#{participant.email}/, email.parts[0].body.to_s
    end
    
    test "should send an accept participant email" do
      group = FactoryBot.create(:group, lock_version: 0)
      FactoryBot.create(:mysyg_setting, group: group)
      FactoryBot.create(:event_detail, group: group)
      participant = FactoryBot.create(:participant, group: group)
      user = FactoryBot.create(:user)
      user.roles << @participant_role
      participant.users << user
      participant.reload
  
      email = UserMailer.accept_participant(participant, group, "ABCDEF")
      
      assert_match /Participant accepted/, email.subject  
      assert_equal user.email, email.to[0]
      assert_match /Thank you again for registering/, email.parts[0].body.to_s
      assert_match /#{user.email}/, email.parts[0].body.to_s
      assert_match /#{user.name}/, email.parts[0].body.to_s
    end
    
    test "should send a new participant email" do
      group = FactoryBot.create(:group, lock_version: 0)
      FactoryBot.create(:mysyg_setting, group: group)
      FactoryBot.create(:event_detail, group: group)
      gc = FactoryBot.create(:user)
      gc.roles << @gc_role
      gc.groups << group
      participant = FactoryBot.create(:participant, group: group)
      user = FactoryBot.create(:user)
      user.roles << @participant_role
      participant.users << user
      participant.reload
  
      email = UserMailer.new_participant(user, participant)
      
      assert_match /New participant/, email.subject  
      assert_equal gc.email, email.to[0]
      assert_match /A new participant has signed up/, email.parts[0].body.to_s
      assert_match /#{participant.email}/, email.parts[0].body.to_s
      assert_match /#{participant.name}/, email.parts[0].body.to_s
    end
  end
