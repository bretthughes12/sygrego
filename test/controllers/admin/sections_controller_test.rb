require "test_helper"

class Admin::SectionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user)
    @section = FactoryBot.create(:section)
    
    sign_in @user
  end

  test "should get index" do
    get admin_sections_url

    assert_response :success
  end

  test "should download section data" do
    get admin_sections_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should show section" do
    get admin_section_url(@section)

    assert_response :success
  end

  test "should not show non existent section" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_section_url(12345678)
    }
  end

  test "should get new" do
    get new_admin_section_url

    assert_response :success
  end

  test "should create section" do
    grade = FactoryBot.create(:grade)
    venue = FactoryBot.create(:venue)
    session = FactoryBot.create(:session)

    assert_difference('Section.count') do
      post admin_sections_path, params: { section: FactoryBot.attributes_for(:section, grade_id: grade.id, venue_id: venue.id, session_id: session.id) }
    end

    assert_response :success
  end

  test "should not create section with errors" do
    grade = FactoryBot.create(:grade)
    venue = FactoryBot.create(:venue)
    session = FactoryBot.create(:session)

    assert_no_difference('Section.count') do
      post admin_sections_path, params: { 
                                section: FactoryBot.attributes_for(:section,
                                                                 name: @section.name,
                                                                 grade: grade,
                                                                 venue: venue,
                                                                 session: session) }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_section_url(@section)

    assert_response :success
  end

  test "should update section" do
    patch admin_section_url(@section), params: { section: { name: "Hockey Open B1" } }

    assert_redirected_to admin_sections_path
    # Reload association to fetch updated data and assert that title is updated.
    @section.reload

    assert_equal "Hockey Open B1", @section.name
  end

  test "should not update section with errors" do
    patch admin_section_url(@section), params: { section: { session_id: nil } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @section.reload

    assert_not_equal nil, @section.session_id
  end

  test "should get new import" do
    get new_import_admin_sections_url

    assert_response :success
  end

  test "should import sections" do
    FactoryBot.create(:grade, name: "Hockey Open B")
    FactoryBot.create(:venue, database_code: "HOCK")
    FactoryBot.create(:session, database_rowid: 1)
    file = fixture_file_upload('section.csv','application/csv')

    assert_difference('Section.count') do
      post import_admin_sections_url, params: { section: { file: file }}
    end

    assert_redirected_to admin_sections_path 
  end

  test "should not import sections when the file is not csv" do
    FactoryBot.create(:grade, name: "Hockey Open B")
    FactoryBot.create(:venue, database_code: "HOCK")
    FactoryBot.create(:session, database_rowid: 1)
    file = fixture_file_upload('not_csv.txt','application/text')

    assert_no_difference('Section.count') do
      post import_admin_sections_url, params: { section: { file: file }}
    end

    assert_response :success
  end

  test "should destroy section" do
    assert_difference("Section.count", -1) do
      delete admin_section_url(@section)
    end

    assert_redirected_to admin_sections_path
  end

  test "should purge draw_file" do
    file = fixture_file_upload('test.pdf','application/pdf')
    @section.draw_file.attach(file)

    patch purge_file_admin_section_url(@section)

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @section.reload

    assert_equal false, @section.draw_file.attached?
  end

  test "should not destroy non existent section" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete admin_section_url(12345678)
    }
  end

  test "should show section via xhr" do
    sign_out @user

    get admin_section_url(@section, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response :success
  end

  test "should not show section via xhr when not authorised" do
    sign_out @user

    get admin_section_url(@section, format: :xml),
        xhr: true,
        headers: {}

    assert_response 401
  end

  test "should not show non existent section via xhr" do
    sign_out @user

    get admin_section_url(123456, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response 404
  end
end
