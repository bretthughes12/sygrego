require "test_helper"

class UserMailerTest < ActionMailer::TestCase
    tests UserMailer
  
    def setup
        @settings = FactoryBot.create(:setting)
        @admin_role = FactoryBot.create(:role, name: 'admin')
        @gc_role = FactoryBot.create(:role, name: 'gc', group_related: true)
        @church_rep_role = FactoryBot.create(:role, name: 'church_rep', group_related: true)
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
  end
