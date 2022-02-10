require "test_helper"

class Admin::VolunteerTypesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @volunteer_type = FactoryBot.create(:volunteer_type)

    sign_in @user
  end

  test "should get index" do
    get admin_volunteer_types_url

    assert_response :success
  end

  test "should download volunteer_type data" do
    get admin_volunteer_types_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should show volunteer_type" do
    get admin_volunteer_type_url(@volunteer_type)

    assert_response :success
  end

  test "should not show non existent volunteer_type" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_volunteer_type_url(12345678)
    }
  end

  test "should get new" do
    get new_admin_volunteer_type_url

    assert_response :success
  end

  test "should create volunteer_type" do
    assert_difference('VolunteerType.count') do
      post admin_volunteer_types_path, params: { volunteer_type: FactoryBot.attributes_for(:volunteer_type) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create volunteer_type with errors" do
    assert_no_difference('VolunteerType.count') do
      post admin_volunteer_types_path, params: { 
                                volunteer_type: FactoryBot.attributes_for(:volunteer_type,
                                  database_code: @volunteer_type.database_code ) }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_volunteer_type_url(@volunteer_type)

    assert_response :success
  end

  test "should update volunteer_type" do
    patch admin_volunteer_type_url(@volunteer_type), params: { volunteer_type: { name: "Gopher" } }

    assert_redirected_to admin_volunteer_types_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @volunteer_type.reload

    assert_equal "Gopher", @volunteer_type.name
  end

  test "should not update volunteer_type with errors" do
    patch admin_volunteer_type_url(@volunteer_type), params: { volunteer_type: { database_code: "Invalid" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @volunteer_type.reload

    assert_not_equal "Invalid", @volunteer_type.database_code
  end

  test "should get new import" do
    get new_import_admin_volunteer_types_url

    assert_response :success
  end

  test "should import volunteer_types" do
    file = fixture_file_upload('volunteer_type.csv','application/csv')

    assert_difference('VolunteerType.count') do
      post import_admin_volunteer_types_url, params: { volunteer_type: { file: file }}
    end

    assert_redirected_to admin_volunteer_types_path 
    assert_match /upload complete/, flash[:notice]
  end

  test "should not import volunteer_types when the file is not csv" do
    file = fixture_file_upload('not_csv.txt','application/text')

    assert_no_difference('VolunteerType.count') do
      post import_admin_volunteer_types_url, params: { volunteer_type: { file: file }}
    end

    assert_response :success
    assert_match /must be in '\.csv' format/, flash[:notice]
  end

  test "should destroy volunteer_type" do
    assert_difference("VolunteerType.count", -1) do
      delete admin_volunteer_type_url(@volunteer_type)
    end

    assert_redirected_to admin_volunteer_types_path
  end

  test "should not destroy non existent volunteer_type" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete admin_volunteer_type_url(12345678)
    }
  end
end
