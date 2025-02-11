require "test_helper"

class Gc::ParticipantsControllerTest < ActionDispatch::IntegrationTest
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
    @participant = FactoryBot.create(:participant, 
      :driver,
      group: @group)
    
    sign_in @user
  end

  test "should get index" do
    get gc_participants_url

    assert_response :success
  end

  test "should download participant data" do
    get gc_participants_url(format: :xlsx)

    assert_response :success
    assert_match %r{application\/vnd.openxmlformats-officedocument.spreadsheetml.sheet}, @response.content_type
  end

  test "should search participants" do
    get search_gc_participants_url

    assert_response :success
  end

  test "should list participants requiring approval" do
    get approvals_gc_participants_url

    assert_response :success
  end

  test "should list eligible drivers" do
    get drivers_gc_participants_url

    assert_response :success
  end

  test "should download drivers nomination form" do
    get drivers_gc_participants_url(format: :pdf)

    assert_response :success
    assert_match %r{application\/pdf}, @response.content_type
  end

  test "should list participant wwccs" do
    get wwccs_gc_participants_url

    assert_response :success
  end

  test "should list participant vaccination status" do
    get vaccinations_gc_participants_url

    assert_response :success
  end

  test "should list participant fees" do
    get group_fees_gc_participants_url

    assert_response :success
  end

  test "should list participant sports" do
    get sports_plan_gc_participants_url

    assert_response :success
  end

  test "should download sports plan" do
    get sports_plan_gc_participants_url(format: :xlsx)

    assert_response :success
    assert_match %r{application\/vnd.openxmlformats-officedocument.spreadsheetml.sheet}, @response.content_type
  end

  test "should list camping preferences" do
    get camping_preferences_gc_participants_url

    assert_response :success
  end

  test "should download camping preferences" do
    get camping_preferences_gc_participants_url(format: :xlsx)

    assert_response :success
    assert_match %r{application\/vnd.openxmlformats-officedocument.spreadsheetml.sheet}, @response.content_type
  end

  test "should list sport notes" do
    get sport_notes_gc_participants_url

    assert_response :success
  end

  test "should download sport notes" do
    get sport_notes_gc_participants_url(format: :xlsx)

    assert_response :success
    assert_match %r{application\/vnd.openxmlformats-officedocument.spreadsheetml.sheet}, @response.content_type
  end

  test "should show participant" do
    get gc_participant_url(@participant)

    assert_response :success
  end

  test "should show participant for church rep user" do
    sign_out @user
    sign_in @church_rep

    get gc_participant_url(@participant)

    assert_response :success
  end

  test "should not show non existent participant" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get gc_participant_url(12345678)
    }
  end

  test "should get new" do
    get new_gc_participant_url

    assert_response :success
  end

  test "should create participant" do
    group = FactoryBot.create(:group)

    assert_difference('Participant.count') do
      post gc_participants_path, params: { participant: FactoryBot.attributes_for(:participant) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create participant with errors" do
    assert_no_difference('Participant.count') do
      post gc_participants_path, params: { 
        participant: FactoryBot.attributes_for(:participant,
          years_attended: 99) }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_gc_participant_url(@participant)

    assert_response :success
  end

  test "should edit driver fields" do
    get edit_driver_gc_participant_url(@participant)

    assert_response :success
  end

  test "should edit wwcc fields" do
    get edit_wwcc_gc_participant_url(@participant)

    assert_response :success
  end

  test "should edit vaccination fields" do
    get edit_vaccination_gc_participant_url(@participant)

    assert_response :success
  end

  test "should edit fee fields" do
    get edit_fees_gc_participant_url(@participant)

    assert_response :success
  end

  test "should edit camping preferences" do
    get edit_camping_preferences_gc_participant_url(@participant)

    assert_response :success
  end

  test "should edit sports notes" do
    get edit_sport_notes_gc_participant_url(@participant)

    assert_response :success
  end

  test "should edit sports" do
    get edit_sports_gc_participant_url(@participant)

    assert_response :success
  end

  test "should update participant" do
    patch gc_participant_url(@participant), 
      params: { participant: { first_name: "Elvis" } }

    assert_redirected_to gc_participants_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_equal "Elvis", @participant.first_name
  end

  test "should not update participant with errors" do
    patch gc_participant_url(@participant), 
      params: { participant: { age: "a" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_not_equal "a", @participant.age
  end

  test "should update driver" do
    patch update_driver_gc_participant_url(@participant), 
      params: { participant: { number_plate: "Elvis1" } }

    assert_redirected_to drivers_gc_participants_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_equal "Elvis1", @participant.number_plate
  end

  test "should not update driver with errors" do
    patch update_driver_gc_participant_url(@participant), 
      params: { participant: { licence_type: "Invalid" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_not_equal "Invalid", @participant.licence_type
  end

  test "should update wwcc" do
    patch update_wwcc_gc_participant_url(@participant), 
      params: { participant: { wwcc_number: "123456" } }

    assert_redirected_to wwccs_gc_participants_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_equal "123456", @participant.wwcc_number
  end

  test "should not update wwcc with errors" do
    Participant.any_instance.stubs(:update).returns(false)

    patch update_wwcc_gc_participant_url(@participant), 
      params: { participant: { wwcc_number: "Invalid" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_not_equal "Invalid", @participant.licence_type
  end

  test "should update vaccination" do
    patch update_vaccination_gc_participant_url(@participant), 
      params: { participant: { vaccination_sighted_by: "Bono" } }

    assert_redirected_to vaccinations_gc_participants_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_equal "Bono", @participant.vaccination_sighted_by
  end

  test "should not update vaccination with errors" do
    patch update_vaccination_gc_participant_url(@participant), 
      params: { participant: { vaccination_sighted_by: "This name is too long" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_not_equal "This name is too long", @participant.vaccination_sighted_by
  end

  test "should update fees" do
    patch update_fees_gc_participant_url(@participant), 
      params: { participant: { amount_paid: 100 } }

    assert_redirected_to group_fees_gc_participants_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_equal 100, @participant.amount_paid
  end

  test "should not update fees with errors" do
    patch update_fees_gc_participant_url(@participant), 
      params: { participant: { amount_paid: "NAN" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_not_equal "NAN", @participant.amount_paid
  end

  # test "should update camping preferences" do
  #   patch update_camping_preferences_gc_participant_url(@participant), 
  #     params: { participant: { camping_preferences: "Sleep on my own" } }

  #   assert_redirected_to camping_preferences_gc_participants_path
  #   assert_match /successfully updated/, flash[:notice]

  #   # Reload association to fetch updated data and assert that title is updated.
  #   @participant.reload

  #   assert_equal "Sleep on my own", @participant.camping_preferences
  # end

  test "should not update camping preferences with errors" do
    Participant.any_instance.stubs(:update).returns(false)

    patch update_camping_preferences_gc_participant_url(@participant), 
      params: { participant: { camping_preferences: "Invalid" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_not_equal "Invalid", @participant.camping_preferences
  end

  # test "should update sport notes" do
  #   patch update_sport_notes_gc_participant_url(@participant), 
  #     params: { participant: { sport_notes: "Must play basketball" } }

  #   assert_redirected_to sport_notes_gc_participants_path
  #   assert_match /successfully updated/, flash[:notice]

  #   # Reload association to fetch updated data and assert that title is updated.
  #   @participant.reload

  #   assert_equal "Must play basketball", @participant.sport_notes
  # end

  test "should not update sport notes with errors" do
    Participant.any_instance.stubs(:update).returns(false)

    patch update_sport_notes_gc_participant_url(@participant), 
      params: { participant: { sport_notes: "Invalid" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_not_equal "Invalid", @participant.sport_notes
  end

  test "should accept a participant" do
    participant_role = FactoryBot.create(:role, name: 'participant', participant_related: true)
    user = FactoryBot.create(:user)
    user.roles << participant_role
    @participant.users << user
    @participant.status = "Requiring Approval"
    @participant.save
    @participant.reload

    patch accept_gc_participant_url(@participant)

    assert_redirected_to approvals_gc_participants_url
    assert_match /was accepted/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_equal "Accepted", @participant.status
  end

  test "should reject a participant" do
    default_group = FactoryBot.create(:group, abbr: "DFLT")
    participant_role = FactoryBot.create(:role, name: 'participant', participant_related: true)
    user = FactoryBot.create(:user)
    user.roles << participant_role
    @participant.users << user
    @participant.status = "Requiring Approval"
    @participant.save
    @participant.reload
    
    patch reject_gc_participant_url(@participant)

    assert_redirected_to approvals_gc_participants_url
    assert_match /was rejected/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_equal "Requiring Approval", @participant.status
    assert_equal default_group, @participant.group
  end

  test "should update a participant to coming" do
    @participant.coming = false
    @participant.save
    
    patch coming_gc_participant_url(@participant)

    assert_redirected_to gc_participants_url

    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_equal true, @participant.coming
  end

  test "should get new import" do
    get new_import_gc_participants_url

    assert_response :success
  end

  test "should import participants" do
    file = fixture_file_upload('participant_gc.csv','application/csv')

    assert_difference('Participant.count') do
      post import_gc_participants_url, params: { participant: { file: file }}
    end

    assert_redirected_to gc_participants_path 
    assert_match /upload complete/, flash[:notice]
  end

  test "should not import participants when the file is not csv" do
    file = fixture_file_upload('not_csv.txt','application/text')

    assert_no_difference('Participant.count') do
      post import_gc_participants_url, params: { participant: { file: file }}
    end

    assert_response :success
    assert_match /must be in '\.csv' format/, flash[:notice]
  end

  test "should get new voucher" do
    get new_voucher_gc_participant_url(@participant)

    assert_response :success
  end

  test "should add a valid voucher" do
    voucher = FactoryBot.create(:voucher, name: "MYVOUCHER")

    post add_voucher_gc_participant_url(@participant), params: { participant: { voucher_name: "MYVOUCHER" }}

    assert_redirected_to edit_gc_participant_path(@participant)
    assert_match /Voucher added/, flash[:notice]

    @participant.reload
    assert_equal voucher, @participant.voucher
  end

  test "should not add an invalid voucher" do
    post add_voucher_gc_participant_url(@participant), params: { participant: { voucher_name: "NOTFOUND" }}

    assert_response :success
    assert_match /is not valid/, flash[:notice]

    @participant.reload
    assert_nil @participant.voucher
  end

  test "should not add a voucher when not sent" do
    post add_voucher_gc_participant_url(@participant), params: { participant: { voucher: "NOTFOUND" }}

    assert_response :success
    assert_match /is not valid/, flash[:notice]

    @participant.reload
    assert_nil @participant.voucher
  end

  test "should delete a voucher" do
    voucher = FactoryBot.create(:voucher, name: "MYVOUCHER")
    @participant.voucher = voucher
    @participant.save

    patch delete_voucher_gc_participant_url(@participant)

    assert_redirected_to edit_gc_participant_path(@participant)
    assert_match /Voucher deleted/, flash[:notice]

    @participant.reload
    assert_nil @participant.voucher
  end

  test "should not delete a non-existent voucher" do
    patch delete_voucher_gc_participant_url(@participant)

    assert_redirected_to edit_gc_participant_path(@participant)

    @participant.reload
    assert_nil @participant.voucher
  end

  test "should destroy participant" do
    assert_difference("Participant.count", -1) do
      delete gc_participant_url(@participant)
    end

    assert_redirected_to gc_participants_path
  end

  test "should not destroy non existent participant" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete gc_participant_url(12345678)
    }
  end
end
