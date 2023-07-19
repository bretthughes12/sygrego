require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/sports_helper'

class Admin::SportsHelperTest < ActionView::TestCase
  include Admin::SportsHelper
  
  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @setting = FactoryBot.create(:setting)
    @sport = FactoryBot.create(:sport)
  end
  
  test "score ranges for results" do
    @sport.allow_negative_score = false
    assert_equal ['Forfeit', *0..99], score_range(@sport)

    @sport.allow_negative_score = true
    assert_equal [*-99..-1, 'Forfeit', *0..99], score_range(@sport)
  end
  
  test "title and explanation for different tie breaks" do
    @sport.ladder_tie_break = "Percentage"
    assert_equal '%', tie_breaker(@sport)
    assert_match /percentage/, ladder_explanation(@sport)

    @sport.ladder_tie_break = "Point Difference"
    assert_equal 'Diff', tie_breaker(@sport)
    assert_match /difference/, ladder_explanation(@sport)

    @sport.ladder_tie_break = "Points For"
    assert_equal 'For', tie_breaker(@sport)
    assert_match /total/, ladder_explanation(@sport)
  end
end