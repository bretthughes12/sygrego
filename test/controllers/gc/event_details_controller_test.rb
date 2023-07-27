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

  test "should get new food certificate" do
    get new_food_certificate_gc_event_detail_url(@event_detail)

    assert_response :success
  end

  test "should get new covid plan" do
    get new_covid_plan_gc_event_detail_url(@event_detail)

    assert_response :success
  end

  test "should get new insurance" do
    get new_insurance_gc_event_detail_url(@event_detail)

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

  test "should update food certificate" do
    file = fixture_file_upload('test.pdf','application/pdf')

    patch update_food_certificate_gc_event_detail_url(@event_detail), params: { event_detail: { food_cert: file }}

    assert_redirected_to home_gc_info_path 
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @event_detail.reload

    assert_equal true, @event_detail.food_cert.attached?
  end

  test "should not update food certificate on bad update" do
    file = fixture_file_upload('test.pdf','application/pdf')
    EventDetail.any_instance.stubs(:update).returns(false)

    patch update_food_certificate_gc_event_detail_url(@event_detail), params: { event_detail: { food_cert: file }}

    assert_response :success

    # Reload association to fetch updated data and assert that title is updated.
    @event_detail.reload

    assert_equal false, @event_detail.food_cert.attached?
  end

  test "should update covid plan" do
    file = fixture_file_upload('test.pdf','application/pdf')

    patch update_covid_plan_gc_event_detail_url(@event_detail), params: { event_detail: { covid_plan: file }}

    assert_redirected_to home_gc_info_path 
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @event_detail.reload

    assert_equal true, @event_detail.covid_plan.attached?
  end

  test "should not update covid plan on bad update" do
    file = fixture_file_upload('test.pdf','application/pdf')
    EventDetail.any_instance.stubs(:update).returns(false)

    patch update_covid_plan_gc_event_detail_url(@event_detail), params: { event_detail: { covid_plan: file }}

    assert_response :success

    # Reload association to fetch updated data and assert that title is updated.
    @event_detail.reload

    assert_equal false, @event_detail.covid_plan.attached?
  end

  test "should update insurance" do
    file = fixture_file_upload('test.pdf','application/pdf')

    patch update_insurance_gc_event_detail_url(@event_detail), params: { event_detail: { insurance: file }}

    assert_redirected_to home_gc_info_path 
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @event_detail.reload

    assert_equal true, @event_detail.insurance.attached?
  end

  test "should not update insurance on bad update" do
    file = fixture_file_upload('test.pdf','application/pdf')
    EventDetail.any_instance.stubs(:update).returns(false)

    patch update_insurance_gc_event_detail_url(@event_detail), params: { event_detail: { insurance: file }}

    assert_response :success

    # Reload association to fetch updated data and assert that title is updated.
    @event_detail.reload

    assert_equal false, @event_detail.insurance.attached?
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

  test "should purge the covid plan from event details" do
    file = fixture_file_upload('test.pdf','application/pdf')
    @event_detail.covid_plan.attach(file)

    patch purge_covid_plan_gc_event_detail_url(@event_detail)

    assert_response :success

    # Reload association to fetch updated data and assert that title is updated.
    @event_detail.reload

    assert_equal false, @event_detail.covid_plan.attached?
  end

  test "should purge the insurance file from event details" do
    file = fixture_file_upload('test.pdf','application/pdf')
    @event_detail.insurance.attach(file)

    patch purge_insurance_gc_event_detail_url(@event_detail)

    assert_response :success

    # Reload association to fetch updated data and assert that title is updated.
    @event_detail.reload

    assert_equal false, @event_detail.insurance.attached?
  end
end
