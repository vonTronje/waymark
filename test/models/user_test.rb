require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "without_access excludes users with shared access and admins" do
    entry = entries(:player_one_shared_view)

    users_without_access = User.without_access(entry)

    assert_not_includes users_without_access, users(:player_one)
    assert_not_includes users_without_access, users(:player_two)
    assert_not_includes users_without_access, users(:admin)
    assert_includes users_without_access, users(:game_master)
  end
end
