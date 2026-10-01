require "test_helper"

# Behavior is tested with Entry as an example Shareable.
class SharePolicyTest < ActiveSupport::TestCase
  setup do
    @shareable = entries(:player_one_character_notes)
    @share = Share.new(shareable: @shareable, user: users(:player_two), access: :viewer)
  end

  test "owner can create, update, and destroy shares" do
    policy = SharePolicy.new(users(:player_one), @share)

    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end

  test "viewer cannot create, update, or destroy shares" do
    @shareable.shares.create!(user: users(:player_two), access: :viewer)
    policy = SharePolicy.new(users(:player_two), @share)

    assert_not policy.create?
    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "editor cannot create, update, or destroy shares" do
    @shareable.shares.create!(user: users(:player_two), access: :editor)
    policy = SharePolicy.new(users(:player_two), @share)

    assert_not policy.create?
    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "admin can create, update, and destroy shares" do
    policy = SharePolicy.new(users(:admin), @share)

    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end

  test "owner cannot update or destroy an owner share" do
    owner_share = @shareable.shares.find_by!(user: users(:player_one), access: :owner)
    policy = SharePolicy.new(users(:player_one), owner_share)

    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "admin cannot update or destroy an owner share" do
    owner_share = @shareable.shares.find_by!(user: users(:player_one), access: :owner)
    policy = SharePolicy.new(users(:admin), owner_share)

    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "neither admin or owner can create an owner share" do
    owner_share = Share.new(shareable: @shareable, user: users(:player_two), access: :owner)

    assert_not SharePolicy.new(users(:player_one), owner_share).create?
    assert_not SharePolicy.new(users(:admin), owner_share).create?
  end

  test "neither admin or owner can promote a share to owner" do
    share = @shareable.shares.create!(user: users(:player_two), access: :viewer)
    share.assign_attributes(access: :owner)

    assert_not SharePolicy.new(users(:player_one), share).update?
    assert_not SharePolicy.new(users(:admin), share).update?
  end
end
