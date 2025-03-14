require File.dirname(__FILE__) + '/../../test_helper'

class Admin::GradesHelperTest < ActionView::TestCase
  include Admin::GradesHelper
  
  def setup
    FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user)
    @setting = FactoryBot.create(:setting)
    @grade = FactoryBot.create(:grade)
  end
  
  test "grade display classes" do
    assert_equal "table-primary", grade_display_class(@grade)

    @grade.over_limit = true
    assert_equal "table-danger", grade_display_class(@grade)

    @grade.one_entry_per_group = true
    assert_equal "table-warning", grade_display_class(@grade)
  end
end