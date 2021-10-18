require "test_helper"

class Gc::EventDetailsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    admin_role = FactoryBot.create(:role, name: 'admin')
    @gc_role = FactoryBot.create(:role, name: 'gc')
    @user = FactoryBot.create(:user)
    @event_detail = FactoryBot.create(:event_detail)
    
    @user.roles.delete(admin_role)
    @user.roles << @gc_role
    @user.groups << @event_detail.group
    
    sign_in @user
  end

  test "should get edit" do
    get edit_gc_event_detail_url(@event_detail)

    assert_response :success
  end

  test "should update event details" do
    patch gc_event_detail_url(@event_detail), params: { event_detail: { estimated_numbers: 40 } }

    assert_redirected_to home_gc_info_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @event_detail.reload

    assert_equal 40, @event_detail.estimated_numbers
  end

  test "should update event details as church_rep" do
    sign_out @user
    church_rep_role = FactoryBot.create(:role, name: 'church_rep')
    @user.roles.delete(@gc_role)
    @user.roles << church_rep_role
    sign_in @user

    patch gc_event_detail_url(@event_detail), params: { event_detail: { estimated_numbers: 40 } }

    assert_redirected_to home_gc_info_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @event_detail.reload

    assert_equal 40, @event_detail.estimated_numbers
  end

  test "should not update group with errors" do
    patch gc_event_detail_url(@event_detail), params: { event_detail: { estimated_numbers: "a" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @event_detail.reload

    assert_not_equal "a", @event_detail.estimated_numbers
  end

  test "should purge the food cert from event details" do
    file = fixture_file_upload('test.pdf','application/pdf')
    @event_detail.food_cert.attach(file)

    patch purge_file_gc_event_detail_url(@event_detail)

    assert_response :success

    # Reload association to fetch updated data and assert that title is updated.
    @event_detail.reload

    assert_equal false, @event_detail.food_cert.attached?
  end
end
