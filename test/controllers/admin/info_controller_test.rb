require "test_helper"

class Admin::InfoControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    @setting = FactoryBot.create(:setting)
    FactoryBot.create(:audit_trail)
    @user = FactoryBot.create(:user, :admin)
    @sport = FactoryBot.create(:sport)
    
    sign_in @user
  end

  test "should get home screen" do
    get home_admin_info_url

    assert_response :success
  end

  test "should get tech stats" do
    get tech_stats_admin_info_url

    assert_response :success
  end

  test "should get event stats" do
    get event_stats_admin_info_url

    assert_response :success
  end

  test "should link the knockout reference" do
    file = fixture_file_upload('test.pdf','application/pdf')
    @setting.knockout_reference.attach(file)

    get knockout_reference_url

    assert_redirected_to rails_blob_path(@setting.knockout_reference)
  end

  test "should link the ladder reference" do
    file = fixture_file_upload('test.pdf','application/pdf')
    @setting.ladder_reference.attach(file)

    get ladder_reference_url

    assert_redirected_to rails_blob_path(@setting.ladder_reference)
  end

  test "should link the results reference" do
    file = fixture_file_upload('test.pdf','application/pdf')
    @setting.results_reference.attach(file)

    get results_reference_url

    assert_redirected_to rails_blob_path(@setting.results_reference)
  end
end
