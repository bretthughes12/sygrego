require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/sport_entries_helper'

class Admin::SportEntriesHelperTest < ActionView::TestCase
  include Admin::SportEntriesHelper
  
  def setup
    @user = FactoryBot.create(:user, :admin)
    @settings = FactoryBot.create(:setting)
    @sport_entry = FactoryBot.create(:sport_entry)
  end
  
  test "sport entry display classes" do
    @sport_entry.status = "Entered"
    assert_equal "table-primary", sport_entry_display_class(@sport_entry)

    @sport_entry.status = "Requested"
    assert_equal "table-warning", sport_entry_display_class(@sport_entry)

    @sport_entry.status = "Waiting List"
    assert_equal "table-dark", sport_entry_display_class(@sport_entry)

    @sport_entry.status = "To Be Confirmed"
    assert_equal "table-danger", sport_entry_display_class(@sport_entry)
  end
  
  test "sport entry status tooltips" do
    @sport_entry.status = "Entered"
    assert_match /You have been entered/, sport_entry_status_tooltip(@sport_entry)

    @sport_entry.status = "Requested"
    assert_match /This entry is 'requested'/, sport_entry_status_tooltip(@sport_entry)

    @sport_entry.status = "Waiting List"
    assert_match /You are on the waiting list/, sport_entry_status_tooltip(@sport_entry)

    @sport_entry.status = "To Be Confirmed"
    assert_match /You must confirm your entry/, sport_entry_status_tooltip(@sport_entry)
  end
  
  test "should show draw link when section has a draw file" do
    draw = fixture_file_upload('test.pdf', 'application/pdf')
    section = FactoryBot.create(:section, draw_file: draw)
    entry = FactoryBot.create(:sport_entry, section_id: section.id)

    assert_equal true, should_show_draw_link(entry)
  end
  
  test "should show confirm button when entry to be confirmed" do
    entry = FactoryBot.create(:sport_entry, status: 'To Be Confirmed')

    assert_equal true, should_show_confirm_button(entry)
  end
  
  test "should show delete link" do
    gc = FactoryBot.create(:user, :gc)
    @current_user = gc
    @settings.team_draws_complete = @settings.indiv_draws_complete = false
    @sport_entry.grade.sport.classification = "Team"
    @sport_entry.grade.status = "Open"
    assert_equal true, should_show_delete_link(@sport_entry)

    @sport_entry.grade.status = "Closed"
    @sport_entry.status = "Waiting List"
    assert_equal true, should_show_delete_link(@sport_entry)

    @sport_entry.status = "Entered"
    @current_user = @user
    assert_equal true, should_show_delete_link(@sport_entry)

    @settings.team_draws_complete = true
    @current_user = gc
    assert_equal false, should_show_delete_link(@sport_entry)

    @settings.indiv_draws_complete = true
    @sport_entry.grade.sport.classification = "Individual"
    assert_equal false, should_show_delete_link(@sport_entry)
  end
end  
