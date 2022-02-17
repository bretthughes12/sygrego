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

  test "should get new import" do
    get new_import_admin_volunteers_url

    assert_response :success
  end

  test "should import volunteers" do
    file = fixture_file_upload('volunteer.csv','application/csv')

    assert_difference('Volunteer.count') do
      post import_admin_volunteers_url, params: { volunteer: { file: file }}
    end

    assert_redirected_to admin_volunteers_path 
    assert_match /upload complete/, flash[:notice]
  end

  test "should not import volunteers when the file is not csv" do
    file = fixture_file_upload('not_csv.txt','application/text')

    assert_no_difference('Volunteer.count') do
      post import_admin_volunteers_url, params: { volunteer: { file: file }}
    end

    assert_response :success
    assert_match /must be in '\.csv' format/, flash[:notice]
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
