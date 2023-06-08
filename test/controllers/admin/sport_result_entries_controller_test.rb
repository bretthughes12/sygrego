require "test_helper"

class Admin::SportResultEntriesControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers 

  setup do
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @group = FactoryBot.create(:group)
    @entry_a = FactoryBot.create(:sport_entry, group: @group)
    @entry_b = FactoryBot.create(:sport_entry, group: @group)
    @admin_sport_result_entry = FactoryBot.
        create(:sport_result_entry,
                entry_a_id: @entry_a.id,
                entry_b_id: @entry_b.id,
                entry_umpire_id: @group.id)
    
    sign_in @user
  end

  test "should get index" do
    get admin_sport_result_entries_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_sport_result_entry_url
    assert_response :success
  end

  test "should not create admin_sport_result_entry with no input" do
    assert_no_difference("SportResultEntry.count") do
      post admin_sport_result_entries_url, params: { admin_sport_result_entry: {  } }
    end

#    assert_redirected_to admin_sport_result_entry_url(SportResultEntry.last)
  end

  test "should show admin_sport_result_entry" do
    get admin_sport_result_entry_url(@admin_sport_result_entry)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_sport_result_entry_url(@admin_sport_result_entry)
    assert_response :success
  end

  test "should update admin_sport_result_entry" do
    patch admin_sport_result_entry_url(@admin_sport_result_entry), params: { admin_sport_result_entry: {  } }
    assert_redirected_to admin_sport_result_entry_url(@admin_sport_result_entry)
  end

  test "should destroy admin_sport_result_entry" do
    assert_difference("SportResultEntry.count", -1) do
      delete admin_sport_result_entry_url(@admin_sport_result_entry)
    end

    assert_redirected_to admin_sport_result_entries_url
  end
end