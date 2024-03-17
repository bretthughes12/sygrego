require "test_helper"

class Admin::GradesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @grade = FactoryBot.create(:grade)
    
    sign_in @user
  end

  test "should get index" do
    get admin_grades_url

    assert_response :success
  end

  test "should download grade data" do
    get admin_grades_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should show grade" do
    get admin_grade_url(@grade)

    assert_response :success
  end

  test "should not show non existent grade" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_grade_url(12345678)
    }
  end

  test "should get new" do
    get new_admin_grade_url

    assert_response :success
  end

  test "should create grade" do
    sport = FactoryBot.create(:sport)

    assert_difference('Grade.count') do
      post admin_grades_path, params: { grade: FactoryBot.attributes_for(:grade, sport_id: sport.id) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create grade with errors" do
    sport = FactoryBot.create(:sport)

    assert_no_difference('Grade.count') do
      post admin_grades_path, params: { 
                                grade: FactoryBot.attributes_for(:grade,
                                                                 name: @grade.name,
                                                                 sport: sport) }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_grade_url(@grade)

    assert_response :success
  end

  test "should update grade" do
    patch admin_grade_url(@grade), params: { grade: { name: "Hockey Open B", database_rowid: 202401 } }

    assert_redirected_to admin_grades_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @grade.reload

    assert_equal "Hockey Open B", @grade.name
  end

  test "should not update grade with errors" do
    patch admin_grade_url(@grade), params: { grade: { max_age: "a" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @grade.reload

    assert_not_equal "a", @grade.max_age
  end

  test "should get new import" do
    get new_import_admin_grades_url

    assert_response :success
  end

  test "should import grades" do
    FactoryBot.create(:sport, name: "Hockey")
    file = fixture_file_upload('grade.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')

    assert_difference('Grade.count') do
      post import_admin_grades_url, params: { grade: { file: file }}
    end

    assert_redirected_to admin_grades_path 
    assert_match /upload complete/, flash[:notice]
  end

  test "should not import grades when the file is not xlsx" do
    file = fixture_file_upload('not_csv.txt','application/text')

    assert_no_difference('Grade.count') do
      post import_admin_grades_url, params: { grade: { file: file }}
    end

    assert_response :success
    assert_match /must be in '\.xlsx' format/, flash[:notice]
  end

  test "should destroy grade" do
    assert_difference("Grade.count", -1) do
      delete admin_grade_url(@grade)
    end

    assert_redirected_to admin_grades_path
  end

  test "should not destroy non existent grade" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete admin_grade_url(12345678)
    }
  end
end
