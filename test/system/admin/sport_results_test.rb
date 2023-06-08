require "application_system_test_case"

class Admin::SportResultsTest < ApplicationSystemTestCase
  setup do
    @admin_sport_result = admin_sport_results(:one)
  end

  test "visiting the index" do
    visit admin_sport_results_url
    assert_selector "h1", text: "Sport results"
  end

  test "should create sport result" do
    visit admin_sport_results_url
    click_on "New sport result"

    click_on "Create Sport result"

    assert_text "Sport result was successfully created"
    click_on "Back"
  end

  test "should update Sport result" do
    visit admin_sport_result_url(@admin_sport_result)
    click_on "Edit this sport result", match: :first

    click_on "Update Sport result"

    assert_text "Sport result was successfully updated"
    click_on "Back"
  end

  test "should destroy Sport result" do
    visit admin_sport_result_url(@admin_sport_result)
    click_on "Destroy this sport result", match: :first

    assert_text "Sport result was successfully destroyed"
  end
end