require "test_helper"

class Admin::RegoChecklistsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @rego_checklist = FactoryBot.create(:rego_checklist)
    
    sign_in @user
  end

  test "should get index" do
    get admin_rego_checklists_url

    assert_response :success
  end

  test "should search rego checklists" do
    get search_admin_rego_checklists_url

    assert_response :success
  end

  test "should download rego checklist data" do
    get admin_rego_checklists_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should show rego checklist" do
    get admin_rego_checklist_url(@rego_checklist)

    assert_response :success
  end

  test "should not show non existent rego checklist" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_rego_checklist_url(12345678)
    }
  end

  test "should get edit" do
    get edit_admin_rego_checklist_url(@rego_checklist)

    assert_response :success
  end

  test "should update rego checklist" do
    patch admin_rego_checklist_url(@rego_checklist), params: { rego_checklist: { registered: true } }

    assert_redirected_to admin_rego_checklists_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @rego_checklist.reload

    assert_equal true, @rego_checklist.registered
  end

  test "should not update rego checklist with errors" do
    patch admin_rego_checklist_url(@rego_checklist), params: { rego_checklist: { rego_mobile: "1234567890123456789012345678901" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @rego_checklist.reload

    assert_not_equal "1234567890123456789012345678901", @rego_checklist.rego_mobile
  end
end
