require "test_helper"

class Admin::LostItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @lost_item = FactoryBot.create(:lost_item)

    sign_in @user
  end

  test "should get index" do
    get admin_lost_items_url

    assert_response :success
  end

  test "should show lost_item" do
    get admin_lost_item_url(@lost_item)

    assert_response :success
  end

  test "should not show non existent lost_item" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_lost_item_url(12345678)
    }
  end

  test "should get new" do
    get new_admin_lost_item_url

    assert_response :success
  end

  test "should create lost_item" do
    assert_difference('LostItem.count') do
      post admin_lost_items_path, params: { lost_item: FactoryBot.attributes_for(:lost_item) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create lost_item with errors" do
    assert_no_difference('LostItem.count') do
      post admin_lost_items_path, params: { 
                                lost_item: FactoryBot.attributes_for(:lost_item,
                                  category: "this category is too long......." ) }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_lost_item_url(@lost_item)

    assert_response :success
  end

  test "should update lost_item" do
    patch admin_lost_item_url(@lost_item), params: { lost_item: { name: "Elvis Presley" } }

    assert_redirected_to admin_lost_items_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @lost_item.reload

    assert_equal "Elvis Presley", @lost_item.name
  end

  test "should not update lost_item with errors" do
    patch admin_lost_item_url(@lost_item), params: { lost_item: { category: "this category is too long......." } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @lost_item.reload

    assert_not_equal "this category is too long.......", @lost_item.category
  end

  test "should destroy lost_item" do
    assert_difference("LostItem.count", -1) do
      delete admin_lost_item_url(@lost_item)
    end

    assert_redirected_to admin_lost_items_path
  end

  test "should not destroy non existent lost_item" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete admin_lost_item_url(12345678)
    }
  end

  test "should purge the lost item photo" do
    file = fixture_file_upload('test.pdf','application/pdf')
    @lost_item.photo.attach(file)

    patch purge_photo_admin_lost_item_url(@lost_item)

    assert_response :success

    # Reload association to fetch updated data and assert that title is updated.
    @lost_item.reload

    assert_equal false, @lost_item.photo.attached?
  end
end
