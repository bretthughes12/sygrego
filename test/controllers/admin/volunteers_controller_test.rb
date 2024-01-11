require "test_helper"

class Admin::VolunteersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @volunteer = FactoryBot.create(:volunteer)
    @type = FactoryBot.create(:volunteer_type, database_code: "SPTC")

    sign_in @user
  end

  test "should get index" do
    get admin_volunteers_url

    assert_response :success
  end

  test "should download volunteer data" do
    get admin_volunteers_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should list saturday sport coordinators" do
    sat = FactoryBot.create(:session, :saturday)
    volunteer = FactoryBot.create(:volunteer, volunteer_type: @type, session: sat)

    get sat_coords_admin_volunteers_url

    assert_response :success
  end

  test "should list sunday sport coordinators" do
    sun = FactoryBot.create(:session, :sunday)
    volunteer = FactoryBot.create(:volunteer, volunteer_type: @type, session: sun)

    get sun_coords_admin_volunteers_url

    assert_response :success
  end

  test "should download sport coordinator notes" do
    get coord_notes_admin_volunteers_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should list all sport volunteers" do
    sun = FactoryBot.create(:session, :sunday)
    volunteer = FactoryBot.create(:volunteer, volunteer_type: @type, session: sun)

    get sport_volunteers_admin_volunteers_url

    assert_response :success
  end

  test "should search volunteers" do
    get search_admin_volunteers_url(search: "Hockey")

    assert_response :success
  end

  test "should download sport volunteers" do
    sun = FactoryBot.create(:session, :sunday)
    volunteer = FactoryBot.create(:volunteer, volunteer_type: @type, session: sun)

    get sport_volunteers_admin_volunteers_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should show volunteer" do
    get admin_volunteer_url(@volunteer)

    assert_response :success
  end

  test "should not show non existent volunteer" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_volunteer_url(12345678)
    }
  end

  test "should get new" do
    get new_admin_volunteer_url

    assert_response :success
  end

  test "should create volunteer" do
    assert_difference('Volunteer.count') do
      post admin_volunteers_path, params: { volunteer: FactoryBot.attributes_for(:volunteer, volunteer_type_id: @type.id) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create volunteer with errors" do
    assert_no_difference('Volunteer.count') do
      post admin_volunteers_path, params: { 
        volunteer: FactoryBot.attributes_for(:volunteer,
        t_shirt_size: "BIG" ) }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_volunteer_url(@volunteer)

    assert_response :success
  end

  test "should edit volunteer collecting gear" do
    get collect_admin_volunteer_url(@volunteer)

    assert_response :success
  end

  test "should edit volunteer returning gear" do
    sun = FactoryBot.create(:session, :sunday)
    group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: group)
    participant = FactoryBot.create(:participant, group: group)
    volunteer = FactoryBot.create(:volunteer, 
      volunteer_type: @type, 
      session: sun, 
      participant: participant)

    get return_admin_volunteer_url(volunteer)

    assert_response :success
  end

  test "should update volunteer" do
    patch admin_volunteer_url(@volunteer), params: { volunteer: { description: "Gopher" } }

    assert_redirected_to admin_volunteers_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @volunteer.reload

    assert_equal "Gopher", @volunteer.description
  end

  test "should not update volunteer with errors" do
    patch admin_volunteer_url(@volunteer), params: { volunteer: { t_shirt_size: "Invalid" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @volunteer.reload

    assert_not_equal "Invalid", @volunteer.t_shirt_size
  end

  test "should update volunteer collecting gear" do
    sat = FactoryBot.create(:session, :saturday)
    group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: group)
    participant = FactoryBot.create(:participant, group: group)
    volunteer = FactoryBot.create(:volunteer, 
      volunteer_type: @type, 
      session: sat, 
      participant: participant)

    patch update_collect_admin_volunteer_url(volunteer), params: { volunteer: { notes: "Took first aid kit" } }

    assert_redirected_to sat_coords_admin_volunteers_url
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    volunteer.reload

    assert_equal "Took first aid kit", volunteer.notes
  end

  test "should not update volunteer collecting gear with errors" do
    sat = FactoryBot.create(:session, :saturday)
    group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: group)
    participant = FactoryBot.create(:participant, group: group)
    volunteer = FactoryBot.create(:volunteer, 
      volunteer_type: @type, 
      session: sat, 
      participant: participant)

    patch update_collect_admin_volunteer_url(volunteer), params: { volunteer: { equipment_out: "Invalid" } }

    assert_response :success

    # Reload association to fetch updated data and assert that title is updated.
    volunteer.reload

    assert_not_equal "Invalid", volunteer.equipment_out
  end

  test "should update volunteer returning gear" do
    sun = FactoryBot.create(:session, :sunday)
    group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: group)
    participant = FactoryBot.create(:participant, group: group)
    volunteer = FactoryBot.create(:volunteer, 
      volunteer_type: @type, 
      session: sun, 
      participant: participant)

    patch update_return_admin_volunteer_url(volunteer), params: { volunteer: { notes: "Left gear at venue" } }

    assert_redirected_to sun_coords_admin_volunteers_url
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    volunteer.reload

    assert_equal "Left gear at venue", volunteer.notes
  end

  test "should not update volunteer returning gear with errors" do
    sat = FactoryBot.create(:session, :saturday)
    group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: group)
    participant = FactoryBot.create(:participant, group: group)
    volunteer = FactoryBot.create(:volunteer, 
      volunteer_type: @type, 
      session: sat, 
      participant: participant)

    patch update_return_admin_volunteer_url(volunteer), params: { volunteer: { equipment_in: "Invalid" } }

    assert_response :success

    # Reload association to fetch updated data and assert that title is updated.
    volunteer.reload

    assert_not_equal "Invalid", volunteer.equipment_in
  end

  test "should get new import" do
    get new_import_admin_volunteers_url

    assert_response :success
  end

  test "should import volunteers" do
    file = fixture_file_upload('volunteer.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')

    assert_difference('Volunteer.count') do
      post import_admin_volunteers_url, params: { volunteer: { file: file }}
    end

    assert_redirected_to admin_volunteers_path 
    assert_match /upload complete/, flash[:notice]
  end

  test "should not import volunteers when the file is not xlsx" do
    file = fixture_file_upload('not_csv.txt','application/text')

    assert_no_difference('Volunteer.count') do
      post import_admin_volunteers_url, params: { volunteer: { file: file }}
    end

    assert_response :success
    assert_match /must be in '\.xlsx' format/, flash[:notice]
  end

  test "should destroy volunteer" do
    assert_difference("Volunteer.count", -1) do
      delete admin_volunteer_url(@volunteer)
    end

    assert_redirected_to admin_volunteers_path
  end

  test "should not destroy non existent volunteer" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete admin_volunteer_url(12345678)
    }
  end
end
