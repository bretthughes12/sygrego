require "test_helper"

class GroupMailerTest < ActionMailer::TestCase
    tests GroupMailer
  
    def setup
        @settings = FactoryBot.create(:setting)
        @admin_role = FactoryBot.create(:role, name: 'admin')
        @gc_role = FactoryBot.create(:role, name: 'gc', group_related: true)
        @church_rep_role = FactoryBot.create(:role, name: 'church_rep', group_related: true)
        FactoryBot.create(:user)
    end
    
    def test_new_group_signup_for_new_group
      group = FactoryBot.create(:group, lock_version: 0)
      church_rep = FactoryBot.create(:user)
      church_rep.roles.delete(@admin_role)
      church_rep.roles << @church_rep_role
      church_rep.groups << group
  
      gc = FactoryBot.create(:user)
      gc.roles.delete(@admin_role)
      gc.roles << @gc_role
      gc.groups << group
      
      email = GroupMailer.new_group_signup(group, church_rep, gc)
      
      assert_match /New group signup details/, email.subject  
      assert_equal @settings.rego_email, email.to[0]  
      assert_equal @settings.admin_email, email.to[1]  
      assert_match /New group signup details have been recorded/, email.parts[0].body.to_s
      assert_match /#{group.name}/, email.parts[0].body.to_s
      assert_match /#{group.address}/, email.parts[0].body.to_s
    end
  end
