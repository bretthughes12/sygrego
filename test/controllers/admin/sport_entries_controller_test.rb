require "test_helper"

class Admin::SportEntriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @group = FactoryBot.create(:group)
    @sport_entry = FactoryBot.create(:sport_entry, group: @group)
    
    sign_in @user
  end

  test "should get index" do
    get admin_sport_entries_url

    assert_response :success
  end

  test "should download sport_entry data" do
    get admin_sport_entries_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should show sport_entry" do
    get admin_sport_entry_url(@sport_entry)

    assert_response :success
  end

  test "should not show non existent sport_entry" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_sport_entry_url(12345678)
    }
  end

  test "should get new" do
    get new_admin_sport_entry_url

    assert_response :success
  end

  test "should create sport_entry" do
    group = FactoryBot.create(:group)

    assert_difference('SportEntry.count') do
      post admin_sport_entries_path, params: { sport_entry: FactoryBot.attributes_for(:sport_entry, group_id: group.id, grade_id: @sport_entry.grade.id) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create sport_entry with errors" do
    assert_no_difference('SportEntry.count') do
      post admin_sport_entries_path, params: { 
        sport_entry: FactoryBot.attributes_for(:sport_entry,
          preferred_section_id: "a") }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_sport_entry_url(@sport_entry)

    assert_response :success
  end

  test "should update sport_entry" do
    section = FactoryBot.create(:section, grade: @sport_entry.grade)

    patch admin_sport_entry_url(@sport_entry), 
    params: { sport_entry: { preferred_section_id: section.id } }

    assert_redirected_to admin_sport_entries_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @sport_entry.reload

    assert_equal section.id, @sport_entry.preferred_section_id
  end

  test "should not update sport_entry with errors" do
    patch admin_sport_entry_url(@sport_entry), 
      params: { sport_entry: { preferred_section_id: "a" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @sport_entry.reload

    assert_not_equal "a", @sport_entry.preferred_section_id
  end

  test "should get new import" do
    get new_import_admin_sport_entries_url

    assert_response :success
  end

  test "should import sport_entries" do
    group = FactoryBot.create(:group, abbr: "CAF", short_name: "Caffeine")
    grade = FactoryBot.create(:grade, name: "Kite Flying Open A")
    file = fixture_file_upload('sport_entry.csv','application/csv')

    assert_difference('SportEntry.count') do
      post import_admin_sport_entries_url, params: { sport_entry: { file: file }}
    end

    assert_redirected_to admin_sport_entries_path 
    assert_match /upload complete/, flash[:notice]
  end

  test "should not import sport_entries when the file is not csv" do
    file = fixture_file_upload('not_csv.txt','application/text')

    assert_no_difference('SportEntry.count') do
      post import_admin_sport_entries_url, params: { sport_entry: { file: file }}
    end

    assert_response :success
    assert_match /must be in '\.csv' format/, flash[:notice]
  end

  test "should destroy sport_entry" do
    assert_difference("SportEntry.count", -1) do
      delete admin_sport_entry_url(@sport_entry)
    end

    assert_redirected_to admin_sport_entries_path
  end

  test "should not destroy non existent sport_entry" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete admin_sport_entry_url(12345678)
    }
  end
end
