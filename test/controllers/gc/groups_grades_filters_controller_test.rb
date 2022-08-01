require "test_helper"

class Gc::GroupsGradesFiltersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers 

  def setup
    FactoryBot.create(:setting)
    @user = FactoryBot.create(:user, :gc)
    @church_rep = FactoryBot.create(:user, :church_rep)
    @mysyg_setting = FactoryBot.create(:mysyg_setting)
    @group = @mysyg_setting.group
    FactoryBot.create(:event_detail, group: @group)
    @user.groups << @group
    @church_rep.groups << @group
    @grade = FactoryBot.create(:grade)
    
    sign_in @user
  end

  test "should hide a team sport grade" do
    assert_difference('GroupsGradesFilter.count') do
      post hide_team_gc_groups_grades_filter_path(@mysyg_setting, group_id: @group.id, grade_id: @grade.id)
    end

    assert_redirected_to edit_team_sports_gc_mysyg_setting_path(@mysyg_setting)
  end

  test "should hide an individual sport grade" do
    assert_difference('GroupsGradesFilter.count') do
      post hide_indiv_gc_groups_grades_filter_path(@mysyg_setting, group_id: @group.id, grade_id: @grade.id)
    end

    assert_redirected_to edit_indiv_sports_gc_mysyg_setting_path(@mysyg_setting)
  end

  test "should show a team sport grade" do
    FactoryBot.create(:groups_grades_filter, group: @group, grade: @grade)

    assert_difference('GroupsGradesFilter.count', -1) do
      delete show_team_gc_groups_grades_filter_path(@mysyg_setting, group_id: @group.id, grade_id: @grade.id)
    end

    assert_redirected_to edit_team_sports_gc_mysyg_setting_path(@mysyg_setting)
  end

  test "should show an individual sport grade" do
    FactoryBot.create(:groups_grades_filter, group: @group, grade: @grade)

    assert_difference('GroupsGradesFilter.count', -1) do
      delete show_indiv_gc_groups_grades_filter_path(@mysyg_setting, group_id: @group.id, grade_id: @grade.id)
    end

    assert_redirected_to edit_indiv_sports_gc_mysyg_setting_path(@mysyg_setting)
  end
end
