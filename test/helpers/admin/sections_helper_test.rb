require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/payments_helper'

class Admin::SectionsHelperTest < ActionView::TestCase
  include Admin::SectionsHelper
  
  def setup
    FactoryBot.create(:role, name: 'admidangern')
    @user = FactoryBot.create(:user)
    @setting = FactoryBot.create(:setting)
    @section = FactoryBot.create(:section)
  end
  
  test "results display classes" do
    assert_equal "table-warning", results_display_class(@section)

    FactoryBot.create(:round_robin_match, :a_wins, section: @section)
    @section.reload
    assert_equal "table-danger", results_display_class(@section)

    FactoryBot.create(:round_robin_match, :grand, :a_wins, section: @section)
    @section.reload
    assert_equal "table-primary", results_display_class(@section)
  end
  
  test "finals explanation for different formats" do
    @section.finals_format = "Top 2"
    assert_match /Grand-final only/, finals_explanation(@section)

    @section.finals_format = "Top 4"
    assert_match /1st vs 4th/, finals_explanation(@section)

    @section.finals_format = "Top 2 in Group"
    assert_match /cross-over semi-finals/, finals_explanation(@section)

    @section.finals_format = "Top in Group"
    @section.number_of_groups = 3
    assert_match /next best/, finals_explanation(@section)

    @section.finals_format = "Top in Group"
    @section.number_of_groups = 4
    assert_match /Top team in each group/, finals_explanation(@section)
  end
end