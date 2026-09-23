require "test_helper"

class NavigationTest < ActionDispatch::IntegrationTest
  test "shows users link, user name and logout button when signed in" do
    sign_in_as users(:game_master)

    get root_path

    assert_select "nav" do
      assert_select "a[href=?]", users_path, text: "Users"
      assert_select "*", text: "Game Master"
      assert_select "form[action=?]", session_path do
        assert_select "input[name=_method][value=delete]", count: 1
        assert_select "button", text: "Log out"
      end
    end
  end

  test "logout button signs the user out" do
    sign_in_as users(:game_master)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end

  test "is not shown when signed out" do
    get new_session_path

    assert_select "nav", count: 0
  end
end
