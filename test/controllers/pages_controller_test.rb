require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @page = FactoryBot.create(:page)
  end

  test "should show page" do
    get static_url(permalink: @page.permalink)

    assert_response :success
  end

  test "should not show non existent page" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get static_url(permalink: 'does_not_exist')
    }
  end
end
