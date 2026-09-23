require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:player_one) }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "new redirects to root when signed in" do
    sign_in_as @user

    get new_session_path

    assert_redirected_to root_path
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "playerone" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "destroy" do
    sign_in_as(User.take)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end
end
