require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/volunteer_helper'

class Admin::VolunteerHelperTest < ActionView::TestCase
  include Admin::VolunteerHelper
  
  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @setting = FactoryBot.create(:setting)
    @volunteer = FactoryBot.create(:volunteer)
  end
  
  test "sport coord display classes" do
    assert_equal "table-dark", sport_coord_display_class(@volunteer)

    @volunteer.collected = true
    assert_equal "table-warning", sport_coord_display_class(@volunteer)

    @volunteer.returned = true
    assert_equal "table-primary", sport_coord_display_class(@volunteer)
  end
  
  test "whether should display t-shirt field" do
    assert_equal false, should_display_t_shirt_flag

    type = FactoryBot.create(:volunteer_type, t_shirt: true)
    @volunteer = FactoryBot.create(:volunteer, volunteer_type: type)
    assert_equal true, should_display_t_shirt_flag
  end
end