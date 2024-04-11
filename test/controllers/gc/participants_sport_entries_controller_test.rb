require "test_helper"

class Gc::ParticipantsSportEntriesControllerTest < ActionDispatch::IntegrationTest
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
    @sport_entry = FactoryBot.create(:sport_entry, group: @group)
    
    sign_in @user
  end

  test "should add participant to sport entry" do
    assert_difference('ParticipantsSportEntry.count') do
      post gc_sport_entry_participants_path(@sport_entry), params: { id: @participant.id }
    end

    assert_redirected_to edit_gc_sport_entry_url(@sport_entry)
    assert_match /Participant added/, flash[:notice]

    @sport_entry.reload
    assert_equal 1, @sport_entry.participants.count
  end

  test "should add participant to sport entry from edit sports" do
    assert_difference('ParticipantsSportEntry.count') do
      post gc_participant_sport_entries_path(@participant), params: { id: @sport_entry.id, return: 'edit_sports' }
    end

    assert_redirected_to edit_sports_gc_participant_url(@participant)
    assert_match /Participant added/, flash[:notice]

    @sport_entry.reload
    assert_equal 1, @sport_entry.participants.count
  end

  test "should not add participant if already in sport entry" do
    @sport_entry.participants << @participant

    assert_no_difference('ParticipantsSportEntry.count') do
      post gc_sport_entry_participants_path(@sport_entry), params: { id: @participant.id }
    end

    assert_redirected_to edit_gc_sport_entry_url(@sport_entry)
    assert_match /Participant added/, flash[:notice]

    @sport_entry.reload
    assert_equal 1, @sport_entry.participants.count
  end

  test "should remove a participant from a sport entry" do
    @sport_entry.participants << @participant
    @sport_entry.captaincy = @participant
    @sport_entry.save
    @sport_entry.reload

    assert_difference('ParticipantsSportEntry.count', -1) do
      delete gc_sport_entry_participant_path(sport_entry_id: @sport_entry.id, id: @participant.id)
    end

    assert_redirected_to edit_gc_sport_entry_url(@sport_entry)
    assert_match /Participant removed/, flash[:notice]

    @sport_entry.reload
    assert_equal 0, @sport_entry.participants.count
  end

  test "should remove a participant from a sport entry from edit sports" do
    @sport_entry.participants << @participant
    @sport_entry.captaincy = @participant
    @sport_entry.save
    @sport_entry.reload

    assert_difference('ParticipantsSportEntry.count', -1) do
      delete gc_sport_entry_participant_path(sport_entry_id: @sport_entry.id, id: @participant.id, return: 'edit_sports')
    end

    assert_redirected_to edit_sports_gc_participant_url(@participant)
    assert_match /Participant removed/, flash[:notice]

    @sport_entry.reload
    assert_equal 0, @sport_entry.participants.count
  end

  test "should not remove a participant from a sport entry it is not in" do
    assert_no_difference('ParticipantsSportEntry.count') do
      delete gc_sport_entry_participant_path(sport_entry_id: @sport_entry.id, id: @participant.id)
    end

    assert_redirected_to edit_gc_sport_entry_url(@sport_entry)
    assert_match /Participant removed/, flash[:notice]

    @sport_entry.reload
    assert_equal 0, @sport_entry.participants.count
  end

  test "should make a participant the captain" do
    @sport_entry.participants << @participant
    @sport_entry.reload

    patch make_captain_gc_sport_entry_participant_path(sport_entry_id: @sport_entry.id, id: @participant.id)

    assert_redirected_to edit_gc_sport_entry_url(@sport_entry)

    @sport_entry.reload
    assert_equal @participant, @sport_entry.captaincy
  end
end
