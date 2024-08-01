require "test_helper"

class Gc::SportEntriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :gc)
    @church_rep = FactoryBot.create(:user, :church_rep)
    @group = FactoryBot.create(:group)
    FactoryBot.create(:mysyg_setting, group: @group)
    FactoryBot.create(:event_detail, group: @group)
    @user.groups << @group
    @church_rep.groups << @group
    @sport_entry = FactoryBot.create(:sport_entry, group: @group)
    
    sign_in @user
  end

  test "should get index" do
    get gc_sport_entries_url

    assert_response :success
  end

  test "should sort index by session" do
    get gc_sport_entries_url(order: 'session')

    assert_response :success
  end

  test "should download sport_entry data" do
    get gc_sport_entries_url(format: :xlsx)

    assert_response :success
    assert_match %r{application\/vnd.openxmlformats-officedocument.spreadsheetml.sheet}, @response.content_type
  end

  test "should get list of sport draws" do
    get sports_draws_gc_sport_entries_url

    assert_response :success
  end

  test "should get list of sport rules" do
    get sports_rules_gc_sport_entries_url

    assert_response :success
  end

  test "should show sport_entry" do
    get gc_sport_entry_url(@sport_entry)

    assert_response :success
  end

  test "should show sport_entry for church rep user" do
    sign_out @user
    sign_in @church_rep

    get gc_sport_entry_url(@sport_entry)

    assert_response :success
  end

  test "should not show non existent sport_entry" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get gc_sport_entry_url(12345678)
    }
  end

  test "should get new" do
    get new_gc_sport_entry_url

    assert_response :success
  end

  test "should create sport_entry" do
    assert_difference('SportEntry.count') do
      post gc_sport_entries_path, params: { 
        sport_entry: FactoryBot.attributes_for(:sport_entry, 
          grade_id: @sport_entry.grade.id) }
    end

    assert_response :redirect
    assert_match /successfully created/, flash[:notice]
  end

  test "should create sport_entry for a specific section" do
    section = FactoryBot.create(:section, grade: @sport_entry.grade)

    assert_difference('SportEntry.count') do
      post gc_sport_entries_path, params: { 
        sport_entry: FactoryBot.attributes_for(:sport_entry, 
          section_id: section.id) }
    end

    assert_response :redirect
    assert_match /successfully created/, flash[:notice]
  end

  test "should create sport_entry from edit sports" do
    participant = FactoryBot.create(:participant, group: @group)

    assert_difference('SportEntry.count') do
      post gc_sport_entries_path, params: { 
        sport_entry: FactoryBot.attributes_for(:sport_entry, 
          grade_id: @sport_entry.grade.id), 
          participant_id: participant.id,
          return: 'edit_sports' }
    end

    assert_redirected_to edit_sports_gc_participant_url(participant)
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create sport entry with errors" do
    assert_no_difference('SportEntry.count') do
      post gc_sport_entries_path, params: { 
        sport_entry: FactoryBot.attributes_for(:sport_entry,
          grade_id: @sport_entry.grade.id,
          preferred_section_id: "a") }
    end

    assert_redirected_to new_gc_sport_entry_url
  end

  test "should not create sport entry with errors from edit sports" do
    participant = FactoryBot.create(:participant, group: @group)
    
    assert_no_difference('SportEntry.count') do
      post gc_sport_entries_path, params: { 
        sport_entry: FactoryBot.attributes_for(:sport_entry,
          grade_id: @sport_entry.grade.id,
          preferred_section_id: "a"),
          participant_id: participant.id,
          return: 'edit_sports' }
    end

    assert_redirected_to edit_sports_gc_participant_url(participant)
  end

  test "should get edit" do
    get edit_gc_sport_entry_url(@sport_entry)

    assert_response :success
  end

  test "should get edit with enough participants" do
    99.times do
      @sport_entry.participants << FactoryBot.create(:participant, group: @group)
    end

    get edit_gc_sport_entry_url(@sport_entry)

    assert_response :success
  end

  test "should update sport_entry" do
    section = FactoryBot.create(:section, grade: @sport_entry.grade)

    patch gc_sport_entry_url(@sport_entry), 
      params: { sport_entry: { preferred_section_id: section.id } }

    assert_redirected_to gc_sport_entries_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @sport_entry.reload

    assert_equal section.id, @sport_entry.preferred_section_id
  end

  test "should not update sport_entry with errors" do
    patch gc_sport_entry_url(@sport_entry), 
      params: { sport_entry: { preferred_section_id: "a" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @sport_entry.reload

    assert_not_equal "a", @sport_entry.preferred_section_id
  end

  test "should confirm sport_entry" do
    entry2 = FactoryBot.create(:sport_entry, status: "Requested", group: @group)

    patch confirm_gc_sport_entry_url(entry2)

    assert_redirected_to gc_sport_entries_path
    assert_match /confirmed/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    entry2.reload

    assert_equal "Entered", entry2.status
  end

#  test "should get new import" do
#    get new_import_gc_sport_entries_url
#
#    assert_response :success
#  end

#  test "should import sport_entries" do
#    file = fixture_file_upload('sport_entry_gc.csv','application/csv')
#
#    assert_difference('SportEntry.count') do
#      post import_gc_sport_entries_url, params: { sport_entry: { file: file }}
#    end

#    assert_redirected_to gc_sport_entries_path 
#    assert_match /upload complete/, flash[:notice]
#  end

#  test "should not import sport_entries when the file is not csv" do
#    file = fixture_file_upload('not_csv.txt','application/text')

#    assert_no_difference('SportEntry.count') do
#      post import_gc_sport_entries_url, params: { sport_entry: { file: file }}
#    end

#    assert_response :success
#    assert_match /must be in '\.csv' format/, flash[:notice]
#  end

  test "should destroy sport_entry" do
    assert_difference("SportEntry.count", -1) do
      delete gc_sport_entry_url(@sport_entry)
    end

    assert_redirected_to gc_sport_entries_path
  end

  test "should not destroy non existent sport_entry" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete gc_sport_entry_url(12345678)
    }
  end
end
