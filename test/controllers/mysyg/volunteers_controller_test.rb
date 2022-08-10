require "test_helper"

class Mysyg::VolunteersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :participant)
    @mysyg_setting = FactoryBot.create(:mysyg_setting)
    @group = @mysyg_setting.group
    FactoryBot.create(:event_detail, group: @group)
    @participant = FactoryBot.create(:participant, group: @group)
    @user.groups << @group
    @user.participants << @participant
    @volunteer = FactoryBot.create(:volunteer, participant: @participant)
    @vacancy = FactoryBot.create(:volunteer)
    
    sign_in @user
  end

  test "should get index" do
    get mysyg_volunteers_url(group: @group.mysyg_setting.mysyg_name)

    assert_response :success
  end

  test "should get edit" do
    get edit_mysyg_volunteer_url(@volunteer, group: @group.mysyg_setting.mysyg_name)

    assert_response :success
  end

  test "should update volunteer" do
    patch mysyg_volunteer_url(@volunteer, group: @group.mysyg_setting.mysyg_name), 
      params: { volunteer: { email: "elvis@presley.com" } }

    assert_redirected_to mysyg_volunteers_path(group: @group.mysyg_setting.mysyg_name)
    assert_match /Thanks for signing up/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @volunteer.reload

    assert_equal "elvis@presley.com", @volunteer.email
  end

  test "should not update volunteer with errors" do
    patch mysyg_volunteer_url(@volunteer, group: @group.mysyg_setting.mysyg_name), 
      params: { volunteer: { t_shirt_size: "INVALID" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @volunteer.reload

    assert_not_equal "INVALID", @volunteer.t_shirt_size
  end
end
