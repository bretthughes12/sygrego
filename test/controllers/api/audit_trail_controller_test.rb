require "test_helper"

class Api::AuditTrailControllerTest < ActionDispatch::IntegrationTest
  def setup
    FactoryBot.create(:setting)
    @remote_user = FactoryBot.create(:user, :admin)
  end

  test "should get audit trails" do
    assert_equal true, @remote_user.role?('admin')
    1.upto(50) do 
      FactoryBot.create(:audit_trail)
    end
    
    get api_audit_trail_index_url(format: :xml),
        xhr: true,
        headers: {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@remote_user.email, @remote_user.password)}
    assert_response :success
#    assert !assigns(:audits).empty?
#    assert_equal 20, assigns(:audits).size
  end

  test "should not get audit trails when not authorized" do
    1.upto(50) do 
      FactoryBot.create(:audit_trail)
    end

    get api_audit_trail_index_url(format: :xml),
    xhr: true,
    headers: {}

    assert_response 401
  end
end
