require "test_helper"

class Sc::IncidentReportsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :sc)
    @incident_report = FactoryBot.create(:incident_report)

    sign_in @user
  end

  test "should get new" do
    get new_sc_incident_report_url

    assert_response :success
  end

  test "should create incident_report" do
    assert_difference('IncidentReport.count') do
      post sc_incident_reports_path, params: { incident_report: FactoryBot.attributes_for(:incident_report) }
    end

    assert_redirected_to new_sc_incident_report_url
    assert_match /Thanks for reporting/, flash[:notice]
  end

  test "should not create incident_report with errors" do
    assert_no_difference('IncidentReport.count') do
      post sc_incident_reports_path, params: { 
                                incident_report: FactoryBot.attributes_for(:incident_report,
                                  section: "this code is too long.............................." ) }
    end

    assert_response :success
  end
end
