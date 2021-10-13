require "test_helper"

class Admin::GroupsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group)
    
    sign_in @user
  end

  test "should get index" do
    get admin_groups_url

    assert_response :success
  end

  test "should search groups" do
    get search_admin_groups_url

    assert_response :success
  end

  test "should download group data" do
    get admin_groups_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should show group" do
    get admin_group_url(@group)

    assert_response :success
  end

  test "should not show non existent group" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get admin_group_url(12345678)
    }
  end

  test "should get new" do
    get new_admin_group_url

    assert_response :success
  end

  test "should create group" do
    assert_difference('Group.count') do
      post admin_groups_path, params: { group: FactoryBot.attributes_for(:group) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create group with errors" do
    assert_no_difference('Group.count') do
      post admin_groups_path, params: { 
                                group: FactoryBot.attributes_for(:group,
                                                                 name: @group.name) }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_admin_group_url(@group)

    assert_response :success
  end

  test "should update group" do
    patch admin_group_url(@group), params: { group: { name: "Caffeine" } }

    assert_redirected_to admin_groups_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @group.reload

    assert_equal "Caffeine", @group.name
  end

  test "should not update group with errors" do
    patch admin_group_url(@group), params: { group: { abbr: "a" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @group.reload

    assert_not_equal "a", @group.abbr
  end

  test "should get new import" do
    get new_import_admin_groups_url

    assert_response :success
  end

  test "should import groups" do
    file = fixture_file_upload('group.csv','application/csv')

    assert_difference('Group.count') do
      post import_admin_groups_url, params: { group: { file: file }}
    end

    assert_redirected_to admin_groups_path 
    assert_match /upload complete/, flash[:notice]
  end

  test "should not import groups when the file is not csv" do
    file = fixture_file_upload('not_csv.txt','application/text')

    assert_no_difference('Group.count') do
      post import_admin_groups_url, params: { group: { file: file }}
    end

    assert_response :success
    assert_match /must be in '\.csv' format/, flash[:notice]
  end

  test "should destroy group" do
    assert_difference("Group.count", -1) do
      delete admin_group_url(@group)
    end

    assert_redirected_to admin_groups_path
  end

  test "should not destroy non existent group" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete admin_group_url(12345678)
    }
  end

#  test "should not destroy group with sections" do
#    FactoryBot.create(:section, group: @group)

#    assert_no_difference("Group.count") do
#      delete admin_group_url(@group)
#    end

#    assert_redirected_to admin_groups_path
#    assert_match /Can't delete/, flash[:notice]
#  end

  test "should show group via xhr" do
    sign_out @user

    get admin_group_url(@group, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response :success
  end

  test "should not show group via xhr when not authorised" do
    sign_out @user

    get admin_group_url(@group, format: :xml),
        xhr: true,
        headers: {}

    assert_response 401
  end

  test "should not show non existent group via xhr" do
    sign_out @user

    get admin_group_url(123456, format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@user.email, @user.password)}

    assert_response 404
  end


  test "should add a group to a user" do
    group = FactoryBot.create(:group)

    patch add_group_admin_user_groups_url(user_id: @user.id, 
                                         params: {group_id: group.id} )

    assert_redirected_to edit_admin_user_path(@user)

    @user.reload

    assert_equal true, @user.groups.include?(group)
  end

  test "should remove a group from a user" do
    group = FactoryBot.create(:group)
    @user.groups << group

    delete purge_admin_user_group_url(user_id: @user.id, id: group)

    assert_redirected_to edit_admin_user_path(@user)

    @user.reload

    assert_equal false, @user.groups.include?(group)
  end
end
