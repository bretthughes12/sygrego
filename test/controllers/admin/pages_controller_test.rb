require "test_helper"

class Admin::PagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @page = FactoryBot.create(:page)
    
    sign_in @user
  end

  test "should get index" do
    get admin_pages_url

    assert_response :success
  end

  test "should show page" do
    get admin_page_url(@page)

    assert_response :success
  end

  test "should not show non existent page" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_page_url(12345678)
    }
  end

  test "should get new" do
    get new_admin_page_url

    assert_response :success
  end

  test "should create page" do
    assert_difference('Page.count') do
      post admin_pages_path, params: { page: FactoryBot.attributes_for(:page) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create page with errors" do
    assert_no_difference('Page.count') do
      post admin_pages_path, params: { 
                                page: FactoryBot.attributes_for(:page,
                                permalink: @page.permalink) }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_page_url(@page)

    assert_response :success
  end

  test "should update page" do
    patch admin_page_url(@page), params: { page: { name: "Hello World" } }

    assert_redirected_to admin_pages_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @page.reload

    assert_equal "Hello World", @page.name
  end

  test "should not update page with errors" do
    patch admin_page_url(@page), params: { page: { permalink: "Too Long...................................................." } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @page.reload

    assert_not_equal "Too Long....................................................", @page.permalink
  end

  test "should destroy page" do
    assert_difference("Page.count", -1) do
      delete admin_page_url(@page)
    end

    assert_redirected_to admin_pages_path
  end

  test "should not destroy non existent page" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete admin_page_url(12345678)
    }
  end
end
