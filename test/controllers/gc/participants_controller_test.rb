require "test_helper"

class Gc::ParticipantsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :gc)
    @group = FactoryBot.create(:group)
    @user.groups << @group
    @participant = FactoryBot.create(:participant, group: @group)
    
    sign_in @user
  end

  test "should get index" do
    get gc_participants_url

    assert_response :success
  end

  test "should search participants" do
    get search_gc_participants_url

    assert_response :success
  end

  test "should download participant data" do
    get gc_participants_url(format: :csv)

    assert_response :success
    assert_match %r{text\/csv}, @response.content_type
  end

  test "should show participant" do
    get gc_participant_url(@participant)

    assert_response :success
  end

  test "should not show non existent participant" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get gc_participant_url(12345678)
    }
  end

  test "should get new" do
    get new_gc_participant_url

    assert_response :success
  end

  test "should create participant" do
    group = FactoryBot.create(:group)

    assert_difference('Participant.count') do
      post gc_participants_path, params: { participant: FactoryBot.attributes_for(:participant) }
    end

    assert_response :success
    assert_match /successfully created/, flash[:notice]
  end

  test "should not create participant with errors" do
    assert_no_difference('Participant.count') do
      post gc_participants_path, params: { 
        participant: FactoryBot.attributes_for(:participant,
          age: "a") }
    end

    assert_response :success
  end

  test "should get edit" do
    get edit_gc_participant_url(@participant)

    assert_response :success
  end

  test "should update participant" do
    patch gc_participant_url(@participant), 
      params: { participant: { first_name: "Elvis" } }

    assert_redirected_to gc_participants_path
    assert_match /successfully updated/, flash[:notice]

    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_equal "Elvis", @participant.first_name
  end

  test "should not update participant with errors" do
    patch gc_participant_url(@participant), 
      params: { participant: { age: "a" } }

    assert_response :success
    # Reload association to fetch updated data and assert that title is updated.
    @participant.reload

    assert_not_equal "a", @participant.age
  end

  test "should get new import" do
    get new_import_gc_participants_url

    assert_response :success
  end

  test "should import participants" do
    file = fixture_file_upload('participant_gc.csv','application/csv')

    assert_difference('Participant.count') do
      post import_gc_participants_url, params: { participant: { file: file }}
    end

    assert_redirected_to gc_participants_path 
    assert_match /upload complete/, flash[:notice]
  end

  test "should not import participants when the file is not csv" do
    file = fixture_file_upload('not_csv.txt','application/text')

    assert_no_difference('Participant.count') do
      post import_gc_participants_url, params: { participant: { file: file }}
    end

    assert_response :success
    assert_match /must be in '\.csv' format/, flash[:notice]
  end

  test "should destroy participant" do
    assert_difference("Participant.count", -1) do
      delete gc_participant_url(@participant)
    end

    assert_redirected_to gc_participants_path
  end

  test "should not destroy non existent participant" do
    assert_raise(ActiveRecord::RecordNotFound) {
      delete gc_participant_url(12345678)
    }
  end
end
