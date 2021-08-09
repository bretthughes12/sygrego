require "test_helper"

class SportTest < ActiveSupport::TestCase
  test "should have 15 per page" do
    assert_equal 15, Sport.per_page
  end
end
