require "test_helper"

class Gc::GroupsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group)
    
    sign_in @user
  end

  test "should get edit" do
    get edit_gc_group_url(@group)

    assert_response :success
  end

  test "should update group" do
    patch gc_group_url(@group), params: { group: { name: "Caffeine" } }

    assert_response :success
#    assert_redirected_to gc_groups_path
    assert_match /Successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @group.reload

    assert_equal "Caffeine", @group.name
  end

  test "should not update group with errors" do
    patch gc_group_url(@group), params: { group: { abbr: "a" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @group.reload

    assert_not_equal "a", @group.abbr
  end
end
