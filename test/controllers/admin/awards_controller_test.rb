require "test_helper"

class Admin::AwardsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :admin)
    @good_sport = FactoryBot.create(:award, :good_sports)
    @spirit = FactoryBot.create(:award, :spirit)
    @vol_award = FactoryBot.create(:award, :volunteer)
    
    sign_in @user
  end

  test "should list good sports" do
    get good_sports_admin_awards_url

    assert_response :success
  end

  test "should list spirit awards" do
    get spirit_admin_awards_url

    assert_response :success
  end

  test "should list volunteer awards" do
    get volunteer_awards_admin_awards_url

    assert_response :success
  end

  test "should get new good sports" do
    get new_good_sports_admin_awards_url

    assert_response :success
  end

  test "should get new spirit" do
    get new_spirit_admin_awards_url

    assert_response :success
  end

  test "should get new volunteer" do
    get new_volunteer_admin_awards_url

    assert_response :success
  end

  test "should edit good sports" do
    get edit_good_sports_admin_award_url(@good_sport)

    assert_response :success
  end

  test "should edit spirit awards" do
    get edit_spirit_admin_award_url(@spirit)

    assert_response :success
  end

  test "should edit volunteer awards" do
    get edit_volunteer_admin_award_url(@vol_award)

    assert_response :success
  end

  test "should create good sports award" do
    assert_difference('Award.count') do
      post create_good_sports_admin_awards_path, params: { award: FactoryBot.attributes_for(:award) }
    end

    assert_response :redirect
    assert_match /Thanks for your nomination/, flash[:notice]
  end

  test "should not create good sports award with errors" do
    assert_no_difference('Award.count') do
      post create_good_sports_admin_awards_path, params: { award: FactoryBot.attributes_for(:award, description: nil) }
    end

    assert_response :success
  end

  test "should create spirit award" do
    assert_difference('Award.count') do
      post create_spirit_admin_awards_path, params: { award: FactoryBot.attributes_for(:award) }
    end

    assert_response :redirect
    assert_match /Thanks for your nomination/, flash[:notice]
  end

  test "should not create spirit award with errors" do
    assert_no_difference('Award.count') do
      post create_spirit_admin_awards_path, params: { award: FactoryBot.attributes_for(:award, description: nil) }
    end

    assert_response :success
  end

  test "should create volunteer award" do
    assert_difference('Award.count') do
      post create_volunteer_admin_awards_path, params: { award: FactoryBot.attributes_for(:award) }
    end

    assert_response :redirect
    assert_match /Thanks for your nomination/, flash[:notice]
  end

  test "should not create volunteer award with errors" do
    assert_no_difference('Award.count') do
      post create_volunteer_admin_awards_path, params: { award: FactoryBot.attributes_for(:award, description: nil) }
    end

    assert_response :success
  end

  test "should update good sports award" do
    patch update_good_sports_admin_award_url(@good_sport), 
      params: { award: { description: "Awesome!" } }

    assert_redirected_to good_sports_admin_awards_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @good_sport.reload

    assert_equal "Awesome!", @good_sport.description
  end

  test "should not update good sports with errors" do
    patch update_good_sports_admin_award_url(@good_sport), 
      params: { award: { description: nil } }

    assert_response :success
    assert_match /There was a problem/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @good_sport.reload

    assert_not_equal nil, @good_sport.description
  end

  test "should update spirit award" do
    patch update_spirit_admin_award_url(@spirit), 
      params: { award: { description: "Awesome!" } }

    assert_redirected_to spirit_admin_awards_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @spirit.reload

    assert_equal "Awesome!", @spirit.description
  end

  test "should not update spirit with errors" do
    patch update_spirit_admin_award_url(@spirit), 
      params: { award: { description: nil } }

    assert_response :success
    assert_match /There was a problem/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @spirit.reload

    assert_not_equal nil, @spirit.description
  end

  test "should update volunteer award" do
    patch update_volunteer_admin_award_url(@vol_award), 
      params: { award: { description: "Awesome!" } }

    assert_redirected_to volunteer_awards_admin_awards_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @vol_award.reload

    assert_equal "Awesome!", @vol_award.description
  end

  test "should not update volunteer award with errors" do
    patch update_volunteer_admin_award_url(@vol_award), 
      params: { award: { description: nil } }

    assert_response :success
    assert_match /There was a problem/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @vol_award.reload

    assert_not_equal nil, @vol_award.description
  end

  test "should flag good sports award" do
    patch flag_good_sports_admin_award_url(@good_sport)

    assert_redirected_to good_sports_admin_awards_path

    # Reload association to fetch updated data and assert that title is updated.
    @good_sport.reload

    assert_equal true, @good_sport.flagged
  end

  test "should flag spirit award" do
    patch flag_spirit_admin_award_url(@spirit)

    assert_redirected_to spirit_admin_awards_path

    # Reload association to fetch updated data and assert that title is updated.
    @spirit.reload

    assert_equal true, @spirit.flagged
  end

  test "should flag volunteer award" do
    patch flag_volunteer_admin_award_url(@vol_award)

    assert_redirected_to volunteer_awards_admin_awards_path

    # Reload association to fetch updated data and assert that title is updated.
    @vol_award.reload

    assert_equal true, @vol_award.flagged
  end

  test "should destroy good sports" do
    assert_difference("Award.count", -1) do
      delete destroy_good_sports_admin_award_url(@good_sport)
    end

    assert_redirected_to good_sports_admin_awards_path
  end

  test "should not destroy non existent good sports" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete destroy_good_sports_admin_award_url(12345678)
    }
  end

  test "should destroy spirit award" do
    assert_difference("Award.count", -1) do
      delete destroy_spirit_admin_award_url(@spirit)
    end

    assert_redirected_to spirit_admin_awards_path
  end

  test "should not destroy non existent spirit award" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete destroy_spirit_admin_award_url(12345678)
    }
  end

  test "should destroy volunteer award" do
    assert_difference("Award.count", -1) do
      delete destroy_volunteer_admin_award_url(@vol_award)
    end

    assert_redirected_to volunteer_awards_admin_awards_path
  end

  test "should not destroy non existent volunteer award" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete destroy_volunteer_admin_award_url(12345678)
    }
  end
end
