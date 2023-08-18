require "test_helper"

class Admin::ParticipantsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @group = FactoryBot.create(:group)
    FactoryBot.create(:mysyg_setting, group: @group)
    FactoryBot.create(:event_detail, group: @group)
    @participant = FactoryBot.create(:participant, group: @group)
    
    sign_in @user
  end

  test "should get index" do
    get admin_participants_url

    assert_response :success
  end

  test "should search participants" do
    get search_admin_participants_url

    assert_response :success
  end

  test "should download participant data" do
    get admin_participants_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should get wwccs" do
    get wwccs_admin_participants_url

    assert_response :success
  end

  test "should download wwcc data" do
    get wwccs_admin_participants_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should get drivers for a group" do
    get drivers_admin_group_participants_url(group_id: @group.id)

    assert_response :success
  end

  test "should download driver nomination for a group" do
    get drivers_admin_group_participants_url(group_id: @group.id, format: :pdf)

    assert_response :success
    assert_match %r{application\/pdf}, @response.content_type
  end

  test "should get tickets" do
    get tickets_admin_participants_url

    assert_response :success
  end

  test "should download new tickets" do
    post ticket_download_admin_participants_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should download updated tickets" do
    post ticket_updates_admin_participants_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should download full ticket extract" do
    get ticket_full_extract_admin_participants_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should reset tickets" do
    participant = FactoryBot.create(:participant, :ticketed, group: @group)

    post ticket_reset_admin_participants_url

    assert_response :success

    participant.reload
    assert_nil participant.registration_nbr
    assert_nil participant.booking_nbr
    assert_equal false, participant.exported
    assert_equal false, participant.dirty
  end

  test "should download participant audit" do
    get participant_audit_admin_participants_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should get day visitors" do
    group = FactoryBot.create(:group, abbr: "DAY")
    FactoryBot.create(:event_detail, group: group)
    day_vis = FactoryBot.create(:participant, group: @group, id: 1234)

    get day_visitors_admin_participants_url

    assert_response :success
  end

  test "should download day visitors" do
    group = FactoryBot.create(:group, abbr: "DAY")
    FactoryBot.create(:event_detail, group: group)
    day_vis = FactoryBot.create(:participant, group: @group, id: 1234)

    get day_visitors_admin_participants_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should show participant" do
    get admin_participant_url(@participant)

    assert_response :success
  end

  test "should not show non existent participant" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_participant_url(12345678)
    }
  end

  test "should get new" do
    get new_admin_participant_url

    assert_response :success
  end

  test "should get new day visitor" do
    group = FactoryBot.create(:group, abbr: "DAY")
    FactoryBot.create(:event_detail, group: group)

    get new_day_visitor_admin_participants_url

    assert_response :success
  end

  test "should create participant" do
    group = FactoryBot.create(:group)

    assert_difference('Participant.count') do
      post admin_participants_path, params: { participant: FactoryBot.attributes_for(:participant, group_id: group.id) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create participant with errors" do
    assert_no_difference('Participant.count') do
      post admin_participants_path, params: { 
        participant: FactoryBot.attributes_for(:participant,
          age: "a") }
    end

    assert_response :success
  end

  test "should create day visitor" do
    group = FactoryBot.create(:group, abbr: "DAY")
    FactoryBot.create(:event_detail, group: group)
    day_vis = FactoryBot.create(:participant, group: @group, id: 1234)

    assert_difference('Participant.count') do
      post create_day_visitor_admin_participants_path, params: { 
        participant: FactoryBot.attributes_for(:participant, 
          :day_visitor, 
          age: 17) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create day visitor with errors" do
    group = FactoryBot.create(:group, abbr: "DAY")
    FactoryBot.create(:event_detail, group: group)
    day_vis = FactoryBot.create(:participant, group: @group, id: 1234)

    assert_no_difference('Participant.count') do
      post create_day_visitor_admin_participants_path, params: { 
        participant: FactoryBot.attributes_for(:participant,
          :day_visitor, 
          age: "a") }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_participant_url(@participant)

    assert_response :success
  end

  test "should edit day visitor" do
    group = FactoryBot.create(:group, abbr: "DAY")
    FactoryBot.create(:event_detail, group: group)
    day_vis = FactoryBot.create(:participant, group: @group, id: 1234)

    get edit_day_visitor_admin_participant_url(day_vis)

    assert_response :success
  end

  test "should update participant" do
    patch admin_participant_url(@participant), 
      params: { participant: { first_name: "Elvis" } }

    assert_redirected_to admin_participants_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_equal "Elvis", @participant.first_name
  end

  test "should not update participant with errors" do
    patch admin_participant_url(@participant), 
      params: { participant: { age: "a" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_not_equal "a", @participant.age
  end

  test "should update day visitor" do
    group = FactoryBot.create(:group, abbr: "DAY")
    FactoryBot.create(:event_detail, group: group)
    day_vis = FactoryBot.create(:participant, group: @group, id: 1234)

    patch update_day_visitor_admin_participant_url(day_vis), 
      params: { participant: { first_name: "Elvis" } }

    assert_redirected_to day_visitors_admin_participants_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    day_vis.reload

    assert_equal "Elvis", day_vis.first_name
  end

  test "should not update day visitor with errors" do
    group = FactoryBot.create(:group, abbr: "DAY")
    FactoryBot.create(:event_detail, group: group)
    day_vis = FactoryBot.create(:participant, group: @group, id: 1234)

    patch update_day_visitor_admin_participant_url(day_vis), 
      params: { participant: { age: "a" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    day_vis.reload

    assert_not_equal "a", day_vis.age
  end

  test "should get new import" do
    get new_import_admin_participants_url

    assert_response :success
  end

  test "should import participants" do
    group = FactoryBot.create(:group, abbr: "CAF")
    file = fixture_file_upload('participant.csv','application/csv')

    assert_difference('Participant.count') do
      post import_admin_participants_url, params: { participant: { file: file }}
    end

    assert_redirected_to admin_participants_path 
    assert_match /upload complete/, flash[:notice]
  end

  test "should not import participants when the file is not csv" do
    file = fixture_file_upload('not_csv.txt','application/text')

    assert_no_difference('Participant.count') do
      post import_admin_participants_url, params: { participant: { file: file }}
    end

    assert_response :success
    assert_match /must be in '\.csv' format/, flash[:notice]
  end

  test "should get new ticket import" do
    get new_ticket_import_admin_participants_url

    assert_response :success
  end

  test "should import ticket data" do
    group = FactoryBot.create(:group, abbr: "DAY")
    FactoryBot.create(:event_detail, group: group)
    participant = FactoryBot.create(:participant, group: @group, id: 1234)
    file = fixture_file_upload('tickets.csv','application/csv')

    assert_difference('Participant.count') do
      post ticket_import_admin_participants_url, params: { participant: { file: file }}
    end

    assert_redirected_to tickets_admin_participants_path 
    assert_match /upload complete/, flash[:notice]
  end

  test "should not import tickets when the file is not csv" do
    file = fixture_file_upload('not_csv.txt','application/text')

    assert_no_difference('Participant.count') do
      post ticket_import_admin_participants_url, params: { participant: { file: file }}
    end

    assert_response :success
    assert_match /must be in '\.csv' format/, flash[:notice]
  end

  test "should get new voucher" do
    get new_voucher_admin_participant_url(@participant)

    assert_response :success
  end

  test "should add a valid voucher" do
    voucher = FactoryBot.create(:voucher, name: "MYVOUCHER")

    post add_voucher_admin_participant_url(@participant), params: { participant: { voucher_name: "MYVOUCHER" }}

    assert_redirected_to edit_admin_participant_path(@participant)
    assert_match /Voucher added/, flash[:notice]

    @participant.reload
    assert_equal voucher, @participant.voucher
  end

  test "should not add an invalid voucher" do
    post add_voucher_admin_participant_url(@participant), params: { participant: { voucher_name: "NOTFOUND" }}

    assert_response :success
    assert_match /is not valid/, flash[:notice]

    @participant.reload
    assert_nil @participant.voucher
  end

  test "should not add a voucher when not sent" do
    post add_voucher_admin_participant_url(@participant), params: { participant: { voucher: "NOTFOUND" }}

    assert_response :success
    assert_match /is not valid/, flash[:notice]

    @participant.reload
    assert_nil @participant.voucher
  end

  test "should delete a voucher" do
    voucher = FactoryBot.create(:voucher, name: "MYVOUCHER")
    @participant.voucher = voucher
    @participant.save

    patch delete_voucher_admin_participant_url(@participant)

    assert_redirected_to edit_admin_participant_path(@participant)
    assert_match /Voucher deleted/, flash[:notice]

    @participant.reload
    assert_nil @participant.voucher
  end

  test "should not delete a non-existent voucher" do
    patch delete_voucher_admin_participant_url(@participant)

    assert_redirected_to edit_admin_participant_path(@participant)

    @participant.reload
    assert_nil @participant.voucher
  end

  test "should destroy participant" do
    assert_difference("Participant.count", -1) do
      delete admin_participant_url(@participant)
    end

    assert_redirected_to admin_participants_path
  end

  test "should not destroy non existent participant" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete admin_participant_url(12345678)
    }
  end

  test "should destroy day visitor" do
    group = FactoryBot.create(:group, abbr: "DAY")
    FactoryBot.create(:event_detail, group: group)
    day_vis = FactoryBot.create(:participant, group: @group, id: 1234)

    assert_difference("Participant.count", -1) do
      delete destroy_day_visitor_admin_participant_url(day_vis)
    end

    assert_redirected_to day_visitors_admin_participants_path
  end

  test "should not destroy non existent day visitor" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete admin_participant_url(12345678)
    }
  end
end
