require File.dirname(__FILE__) + '/../../test_helper'

class Admin::RoundRobinMatchesHelperTest < ActionView::TestCase
  include Admin::RoundRobinMatchesHelper
  
  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @setting = FactoryBot.create(:setting)
    @match = FactoryBot.create(:round_robin_match)
  end
  
  test "forfeit display class" do
    assert_equal "table-danger", forfeit_display_class(true)
    assert_equal "table-dark", forfeit_display_class(false)
  end
end  
