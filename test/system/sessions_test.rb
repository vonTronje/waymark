require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  test "signing in redirects to the profile and shows the navigation" do
    visit new_session_path

    sign_in_as_game_master

    assert_current_path user_path(users(:game_master))
    assert_selector "nav", text: "Game Master"
    assert_no_link "Users"
  end

  test "signing in with a wrong password shows an error" do
    visit new_session_path
    fill_in "Email address", with: "game.master@test.de"
    fill_in "Password", with: "wrong"
    click_on "Sign in"

    assert_text "Try another email address or password."
    assert_current_path new_session_path
    assert_no_selector "nav"
  end

  test "logging out returns to the login page" do
    sign_in_as_game_master

    click_on "Log out"

    assert_current_path new_session_path
    assert_no_selector "nav"
  end

  private
    def sign_in_as_game_master
      visit new_session_path
      fill_in "Email address", with: "game.master@test.de"
      fill_in "Password", with: "gamemaster"
      click_on "Sign in"
    end
end
