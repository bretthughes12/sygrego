require "test_helper"

class Gc::ParticipantExtrasControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :gc)
    @church_rep = FactoryBot.create(:user, :church_rep)
    @group = FactoryBot.create(:group)
    FactoryBot.create(:event_detail, group: @group)
    @user.groups << @group
    @church_rep.groups << @group
    @participant = FactoryBot.create(:participant, group: @group)
    @group_extra = FactoryBot.create(:group_extra, group: @group)
    @participant_extra = FactoryBot.create(:participant_extra, participant: @participant, group_extra: @group_extra)
    
    sign_in @user
  end

  test "should list participant extras" do
    get gc_participant_extras_path

    assert_response :success
  end
end
