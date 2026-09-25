require "application_system_test_case"

class EntriesSharingTest < ApplicationSystemTestCase
  test "owner can share viewer access to an entry" do
    entry = entries(:player_one_character_notes)

    visit new_session_path
    fill_in "Email address", with: "player.one@test.de"
    fill_in "Password", with: "playerone"
    click_on "Sign in"
    assert_current_path user_path(users(:player_one))

    visit entry_path(entry)
    click_on "Sharing"
    assert_selector ".access-badge", text: "owner"

    within "#shares" do
      select "Player Two", from: "User"
      select "Viewer", from: "Access"
      click_on "Share"
    end

    assert_text "Share was successfully created."
    click_on "Sharing"
    assert_text "Player Two"

    click_on "Log out"
    assert_current_path new_session_path

    fill_in "Email address", with: "player.two@test.de"
    fill_in "Password", with: "playertwo"
    click_on "Sign in"
    assert_current_path user_path(users(:player_two))

    visit entry_path(entry)
    click_on "Sharing"
    assert_selector ".access-badge", text: "viewer"
    assert_no_selector "#shares"
    assert_no_link "Edit this entry"
  end
end
