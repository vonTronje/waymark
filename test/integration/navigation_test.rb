require "test_helper"

class NavigationTest < ActionDispatch::IntegrationTest
  test "shows user name link and logout button without users link for a regular user" do
    game_master = users(:game_master)
    sign_in_as game_master

    get user_path(game_master)

    assert_select "nav" do
      assert_select "a[href=?]", users_path, text: "Users", count: 0
      assert_select "a[href=?]", user_path(game_master), text: "Game Master"
      assert_select "form[action=?]", session_path do
        assert_select "input[name=_method][value=delete]", count: 1
        assert_select "button", text: "Log out"
      end
    end
  end

  test "shows users link and name link for an admin" do
    admin = users(:admin)
    sign_in_as admin

    get user_path(admin)

    assert_select "nav" do
      assert_select "a[href=?]", users_path, text: "Users"
      assert_select "a[href=?]", user_path(admin), text: "Admin"
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
