require "application_system_test_case"

class Admin::SportResultEntriesTest < ApplicationSystemTestCase
  setup do
    @admin_sport_result_entry = admin_sport_result_entries(:one)
  end

  test "visiting the index" do
    visit admin_sport_result_entries_url
    assert_selector "h1", text: "Sport result entries"
  end

  test "should create sport result entry" do
    visit admin_sport_result_entries_url
    click_on "New sport result entry"

    click_on "Create Sport result entry"

    assert_text "Sport result entry was successfully created"
    click_on "Back"
  end

  test "should update Sport result entry" do
    visit admin_sport_result_entry_url(@admin_sport_result_entry)
    click_on "Edit this sport result entry", match: :first

    click_on "Update Sport result entry"

    assert_text "Sport result entry was successfully updated"
    click_on "Back"
  end

  test "should destroy Sport result entry" do
    visit admin_sport_result_entry_url(@admin_sport_result_entry)
    click_on "Destroy this sport result entry", match: :first

    assert_text "Sport result entry was successfully destroyed"
  end
end