require "test_helper"

class LostItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @lost_item = FactoryBot.create(:lost_item, lock_version: 1)
  end

  test "should get index" do
    get lost_items_url

    assert_response :success
  end

  test "should search lost items" do
    get search_lost_items_url(search: "T Shirt")

    assert_response :success
  end

  test "should show lost_item" do
    get lost_item_url(@lost_item)

    assert_response :success
  end

  test "should not show non existent lost_item" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get lost_item_url(12345678)
    }
  end

  test "should get edit" do
    get edit_lost_item_url(@lost_item)

    assert_response :success
  end

  test "should update lost_item" do
    patch lost_item_url(@lost_item), 
      params: { lost_item: 
        { name: "Elvis Presley",
          address: "123 Main St",
          suburb: "Disneyland",
          postcode: "3333",
          phone_number: "0444-333-222",
          email: "elvis@elvis.com" } }

    assert_redirected_to lost_items_path
    assert_match /claimed/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @lost_item.reload

    assert_equal "Elvis Presley", @lost_item.name
  end

  test "should not update lost_item with errors" do
    patch lost_item_url(@lost_item), params: { lost_item: { name: "Elvis Presley" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @lost_item.reload

    assert_not_equal "Elvis Presley", @lost_item.name
  end

  test "should not update stale lost item" do
    patch lost_item_url(@lost_item), 
      params: { lost_item: 
        { name: "Elvis Presley",
          address: "123 Main St",
          suburb: "Disneyland",
          postcode: "3333",
          phone_number: "0444-333-222",
          email: "elvis@elvis.com",
          lock_version: 0 } }

    assert_redirected_to lost_items_path
    assert_match /Somebody else has updated/, flash[:notice]
  end
end
