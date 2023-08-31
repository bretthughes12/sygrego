require "test_helper"

class ModelAuditJobTest < ActiveJob::TestCase
  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @setting = FactoryBot.create(:setting)
  end

  test "audit record is created" do
    sport = FactoryBot.create(:sport)

    assert_difference('AuditTrail.count') do
      ModelAuditJob.perform_now(sport, "CREATE")
    end

    audit = AuditTrail.last
    assert_equal 'Sport', audit.record_type
    assert_equal 'CREATE', audit.event
    assert_nil audit.user_id
  end
end
