require "test_helper"

class Gc::EventDetailsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :gc)
    @event_detail = FactoryBot.create(:event_detail)
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

    church_rep_user = FactoryBot.create(:user, :church_rep)
    church_rep_user.groups << @event_detail.group
    sign_in church_rep_user

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

    patch purge_food_certificate_gc_event_detail_url(@event_detail)

    assert_response :success

    # Reload association to fetch updated data and assert that title is updated.
    @event_detail.reload

    assert_equal false, @event_detail.food_cert.attached?
  end
end
