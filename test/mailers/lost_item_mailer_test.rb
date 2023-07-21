require "test_helper"

class LostItemMailerTest < ActionMailer::TestCase
    tests LostItemMailer
  
    def setup
      @admin_role = FactoryBot.create(:role, name: 'admin')
      @user = FactoryBot.create(:user)
      @setting = FactoryBot.create(:setting)
      @item = FactoryBot.create(:lost_item, :claimed)
    end
    
    test "should send a found lost property email" do
      email = LostItemMailer.claimed_item(@item)
      
      assert_match /Claimed lost property/, email.subject  
      assert_equal @setting.lost_property_email, email.to[0]
      assert_match /An item of lost property has been claimed/, email.parts[0].body.to_s
      assert_match /#{@item.name}/, email.parts[0].body.to_s
      assert_match /#{@item.email}/, email.parts[0].body.to_s
    end
  end
