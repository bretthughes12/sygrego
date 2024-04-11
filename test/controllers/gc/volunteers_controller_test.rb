require "test_helper"

class Gc::VolunteersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :gc)
    @church_rep = FactoryBot.create(:user, :church_rep)
    @group = FactoryBot.create(:group)
    FactoryBot.create(:mysyg_setting, group: @group)
    FactoryBot.create(:event_detail, group: @group)
    @user.groups << @group
    @church_rep.groups << @group
    @participant = FactoryBot.create(:participant, group: @group)
    @participant16 = FactoryBot.create(:participant, :under18, group: @group)
    @volunteer16 = FactoryBot.create(:volunteer_type, age_category: "Over 16")
    @volunteer = FactoryBot.create(:volunteer, participant: @participant)
    @volunteer2 = FactoryBot.create(:volunteer, volunteer_type: @volunteer16)
    @vacancy = FactoryBot.create(:volunteer)
    
    sign_in @user
  end

  test "should get index" do
    get gc_volunteers_url

    assert_response :success
  end

  test "should get available volunteers" do
    get available_gc_volunteers_url

    assert_response :success
  end

  test "should search available volunteers" do
    get search_gc_volunteers_url(search: "Elvis")

    assert_response :success
  end

  test "should show volunteer" do
    get gc_volunteer_url(@volunteer)

    assert_response :success
  end

  test "should show volunteer for church rep user" do
    sign_out @user
    sign_in @church_rep

    get gc_volunteer_url(@volunteer)

    assert_response :success
  end

  test "should not show non existent volunteer" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get gc_volunteer_url(12345678)
    }
  end

  test "should get edit" do
    get edit_gc_volunteer_url(@volunteer)

    assert_response :success
  end

  test "should get edit where 16 year olds can apply" do
    get edit_gc_volunteer_url(@volunteer2)

    assert_response :success
  end

  test "should update volunteer" do
    patch gc_volunteer_url(@volunteer), 
      params: { volunteer: { email: "elvis@presley.com" } }

    assert_redirected_to gc_volunteers_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @volunteer.reload

    assert_equal "elvis@presley.com", @volunteer.email
  end

  test "should not update volunteer with errors" do
    patch gc_volunteer_url(@volunteer), 
      params: { volunteer: { t_shirt_size: "INVALID" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @volunteer.reload

    assert_not_equal "INVALID", @volunteer.t_shirt_size
  end

  test "should not update volunteer with errors when 16 year olds can apply" do
    patch gc_volunteer_url(@volunteer2), 
      params: { volunteer: { t_shirt_size: "INVALID" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @volunteer2.reload

    assert_not_equal "INVALID", @volunteer2.t_shirt_size
  end

  test "should release volunteer" do
    patch release_gc_volunteer_url(@volunteer)

    assert_redirected_to gc_volunteers_path
    assert_match /Volunteer released/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @volunteer.reload

    assert_nil @volunteer.participant
    assert_nil @volunteer.email
    assert_nil @volunteer.mobile_number
    assert_nil @volunteer.t_shirt_size
  end
end
