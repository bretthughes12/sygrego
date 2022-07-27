require "test_helper"

class Gc::GroupExtrasControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :gc)
    @church_rep = FactoryBot.create(:user, :church_rep)
    @group = FactoryBot.create(:group)
    @user.groups << @group
    @church_rep.groups << @group
    @group_extra = FactoryBot.create(:group_extra, group: @group)
    
    sign_in @user
  end

  test "should get index" do
    get gc_group_extras_url

    assert_response :success
  end

  test "should show group_extra" do
    get gc_group_extra_url(@group_extra)

    assert_response :success
  end

  test "should show group_extra for church rep user" do
    sign_out @user
    sign_in @church_rep

    get gc_group_extra_url(@group_extra)

    assert_response :success
  end

  test "should not show non existent group_extra" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get gc_group_extra_url(12345678)
    }
  end

  test "should get new" do
    get new_gc_group_extra_url

    assert_response :success
  end

  test "should create group_extra" do
    group = FactoryBot.create(:group)

    assert_difference('GroupExtra.count') do
      post gc_group_extras_path, params: { group_extra: FactoryBot.attributes_for(:group_extra) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create group_extra with errors" do
    assert_no_difference('GroupExtra.count') do
      post gc_group_extras_path, params: { 
        group_extra: FactoryBot.attributes_for(:group_extra,
          cost: nil) }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_gc_group_extra_url(@group_extra)

    assert_response :success
  end

  test "should update group_extra" do
    patch gc_group_extra_url(@group_extra), 
      params: { group_extra: { name: "Elvis" } }

    assert_redirected_to gc_group_extras_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @group_extra.reload

    assert_equal "Elvis", @group_extra.name
  end

  test "should not update group_extra with errors" do
    patch gc_group_extra_url(@group_extra), 
      params: { group_extra: { cost: "a" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @group_extra.reload

    assert_not_equal "a", @group_extra.cost
  end

  test "should destroy group_extra" do
    assert_difference("GroupExtra.count", -1) do
      delete gc_group_extra_url(@group_extra)
    end

    assert_redirected_to gc_group_extras_path
  end

  test "should not destroy non existent group_extra" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete gc_group_extra_url(12345678)
    }
  end
end
