require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @player_one = users(:player_one)
    @player_two = users(:player_two)
  end

  test "admin can get index" do
    sign_in_as @admin

    get users_url
    assert_response :success
  end

  test "user cannot get index" do
    sign_in_as @player_one

    get users_url
    assert_redirected_to user_path(@player_one)
  end

  test "admin can get new" do
    sign_in_as @admin

    get new_user_url
    assert_response :success
  end

  test "user cannot get new" do
    sign_in_as @player_one

    get new_user_url
    assert_redirected_to user_path(@player_one)
  end

  test "admin can create user" do
    sign_in_as @admin

    assert_difference("User.count") do
      post users_url, params: { user: { name: "New Player", email_address: "new.player@test.de", password: "newplayer" } }
    end

    assert_redirected_to user_url(User.last)
  end

  test "user cannot create user" do
    sign_in_as @player_one

    assert_no_difference("User.count") do
      post users_url, params: { user: { name: "New Player", email_address: "new.player@test.de", password: "newplayer" } }
    end

    assert_redirected_to user_path(@player_one)
  end

  test "admin can show any user" do
    sign_in_as @admin

    get user_url(@player_one)
    assert_response :success
  end

  test "user can show themselves" do
    sign_in_as @player_one

    get user_url(@player_one)
    assert_response :success
  end

  test "user cannot show another user" do
    sign_in_as @player_one

    get user_url(@player_two)
    assert_redirected_to user_path(@player_one)
  end

  test "admin can get edit for any user" do
    sign_in_as @admin

    get edit_user_url(@player_one)
    assert_response :success
  end

  test "user can get edit for themselves" do
    sign_in_as @player_one

    get edit_user_url(@player_one)
    assert_response :success
  end

  test "user cannot get edit for another user" do
    sign_in_as @player_one

    get edit_user_url(@player_two)
    assert_redirected_to user_path(@player_one)
  end

  test "admin can update any user" do
    sign_in_as @admin

    patch user_url(@player_one), params: { user: { name: "Updated" } }
    assert_redirected_to user_url(@player_one)
    assert_equal "Updated", @player_one.reload.name
  end

  test "user can update themselves" do
    sign_in_as @player_one

    patch user_url(@player_one), params: { user: { name: "Updated" } }
    assert_redirected_to user_url(@player_one)
    assert_equal "Updated", @player_one.reload.name
  end

  test "user cannot update another user" do
    sign_in_as @player_one

    patch user_url(@player_two), params: { user: { name: "Updated" } }
    assert_redirected_to user_path(@player_one)
    assert_equal "Player Two", @player_two.reload.name
  end

  test "admin can destroy user" do
    sign_in_as @admin

    assert_difference("User.count", -1) do
      delete user_url(@player_one)
    end

    assert_redirected_to users_url
  end

  test "user cannot destroy a user" do
    sign_in_as @player_one

    assert_no_difference("User.count") do
      delete user_url(@player_two)
    end

    assert_redirected_to user_path(@player_one)
  end
end
