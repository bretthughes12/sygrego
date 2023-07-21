require "test_helper"

class SportEntryMailerTest < ActionMailer::TestCase
    tests SportEntryMailer
  
    def setup
      @admin_role = FactoryBot.create(:role, name: 'admin')
      @user = FactoryBot.create(:user)
      @gc_role = FactoryBot.create(:role, name: 'gc', group_related: true)
      @setting = FactoryBot.create(:setting)
      @entry = FactoryBot.create(:sport_entry)
    end
    
    test "should send restricted sport withdrawal email" do
      group = FactoryBot.create(:group)
      FactoryBot.create(:event_detail, group: group)
      entry2 = FactoryBot.create(:sport_entry, grade: @entry.grade, status: "Waiting List", group: group)
      
      email = SportEntryMailer.restricted_sport_withdrawal(@entry)
      
      assert_match /Withdrawal from/, email.subject  
      assert_equal 'sports@stateyouthgames.com', email.to[0]
      assert_match /An entry has been withdrawn/, email.parts[0].body.to_s
      assert_match /#{@entry.section_name}/, email.parts[0].body.to_s
      assert_match /#{group.short_name}/, email.parts[0].body.to_s
    end
    
    test "should send restricted sport offer email" do
      group = FactoryBot.create(:group)
      FactoryBot.create(:event_detail, group: group)
      gc = FactoryBot.create(:user)
      gc.roles << @gc_role
      gc.groups << group
      entry2 = FactoryBot.create(:sport_entry, grade: @entry.grade, status: "Waiting List", group: group)
      
      email = SportEntryMailer.restricted_sport_offer(@entry)
      
      assert_match /Restricted Sports Offer/, email.subject  
      assert_equal 'sports@stateyouthgames.com', email.to[0]
      assert_equal gc.email, email.bcc[0]
      assert_match /We have had a group withdrawal/, email.parts[0].body.to_s
      assert_match /#{@entry.section_name}/, email.parts[0].body.to_s
    end
    
    test "should send draw entry withdrawal email" do
      group = FactoryBot.create(:group)
      FactoryBot.create(:event_detail, group: group)
      
      email = SportEntryMailer.draw_entry_withdrawal(@entry)
      
      assert_match /Draw affected: Withdrawal/, email.subject  
      assert_equal 'sports@stateyouthgames.com', email.to[0]
      assert_match /An entry has been withdrawn from a sport section/, email.parts[0].body.to_s
      assert_match /#{@entry.section_name}/, email.parts[0].body.to_s
    end
    
    test "should send draw entry addition email" do
      group = FactoryBot.create(:group)
      FactoryBot.create(:event_detail, group: group)
      
      email = SportEntryMailer.draw_entry_addition(@entry)
      
      assert_match /Draw affected: New/, email.subject  
      assert_equal 'sports@stateyouthgames.com', email.to[0]
      assert_match /A new entry has been added to a sport section/, email.parts[0].body.to_s
      assert_match /#{@entry.section_name}/, email.parts[0].body.to_s
    end
  end
