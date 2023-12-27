require File.dirname(__FILE__) + '/../../test_helper'

class Admin::AwardsHelperTest < ActionView::TestCase
  include Admin::AwardsHelper
  
  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @setting = FactoryBot.create(:setting)
    @award = FactoryBot.create(:award)
  end
  
  test "award display classes" do
    @award.flagged = true
    assert_equal "table-primary", award_display_class(@award)

    @award.flagged = false
    assert_equal "table-secondary", award_display_class(@award)
  end
end