require "test_helper"

class Admin::IncidentReportsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @incident_report = FactoryBot.create(:incident_report)

    sign_in @user
  end

  test "should get index" do
    get admin_incident_reports_url

    assert_response :success
  end

  test "should download incident_report data as csv" do
    get admin_incident_reports_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should download incident_report data as pdf" do
    get admin_incident_reports_url(format: :pdf)

    assert_response :success
    assert_match %r{application\/pdf}, @response.content_type
  end

  test "should show incident_report" do
    get admin_incident_report_url(@incident_report)

    assert_response :success
  end

  test "should not show non existent incident_report" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_incident_report_url(12345678)
    }
  end

  test "should get new" do
    get new_admin_incident_report_url

    assert_response :success
  end

  test "should create incident_report" do
    assert_difference('IncidentReport.count') do
      post admin_incident_reports_path, params: { incident_report: FactoryBot.attributes_for(:incident_report) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create incident_report with errors" do
    assert_no_difference('IncidentReport.count') do
      post admin_incident_reports_path, params: { 
                                incident_report: FactoryBot.attributes_for(:incident_report,
                                  section: "this code is too long.............................." ) }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_incident_report_url(@incident_report)

    assert_response :success
  end

  test "should update incident_report" do
    patch admin_incident_report_url(@incident_report), params: { incident_report: { name: "Gopher" } }

    assert_redirected_to admin_incident_reports_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @incident_report.reload

    assert_equal "Gopher", @incident_report.name
  end

  test "should not update incident_report with errors" do
    patch admin_incident_report_url(@incident_report), params: { incident_report: { section: "this code is too long.............................." } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @incident_report.reload

    assert_not_equal "this code is too long..............................", @incident_report.section
  end

  test "should destroy incident_report" do
    assert_difference("IncidentReport.count", -1) do
      delete admin_incident_report_url(@incident_report)
    end

    assert_redirected_to admin_incident_reports_path
  end

  test "should not destroy non existent incident_report" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete admin_incident_report_url(12345678)
    }
  end
end
