require "test_helper"

class Admin::SportResultsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers 

    setup do
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @group = FactoryBot.create(:group)
    @section = FactoryBot.create(:section)
    @entry_a = FactoryBot.create(:sport_entry, group: @group, grade: @section.grade, section: @section)
    @entry_b = FactoryBot.create(:sport_entry, group: @group, grade: @section.grade, section: @section)
    @admin_sport_result_entry = FactoryBot.
        create(:sport_result_entry,
                entry_a_id: @entry_a.id,
                entry_b_id: @entry_b.id,
                entry_umpire_id: @group.id)
    
    sign_in @user
  end

  test "should get index" do
    get admin_sport_results_url
    assert_response :success
  end

  test "should show admin_sport_result" do
    get admin_sport_result_url(@section)
    assert_response :success
  end

end