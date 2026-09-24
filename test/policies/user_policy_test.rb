require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  def setup
    @admin = users(:admin)
    @player_one = users(:player_one)
    @player_two = users(:player_two)
  end

  test "admin can index, create, and destroy" do
    policy = UserPolicy.new(@admin, User)
    assert policy.index?
    assert policy.create?
    assert policy.destroy?
  end

  test "user can index but not create or destroy" do
    policy = UserPolicy.new(@player_one, User)
    assert policy.index?
    assert_not policy.create?
    assert_not policy.destroy?
  end

  test "admin can show and update any user" do
    policy = UserPolicy.new(@admin, @player_one)
    assert policy.show?
    assert policy.update?
  end

  test "user can show and update themselves" do
    policy = UserPolicy.new(@player_one, @player_one)
    assert policy.show?
    assert policy.update?
  end

  test "user cannot show or update another user" do
    policy = UserPolicy.new(@player_one, @player_two)
    assert_not policy.show?
    assert_not policy.update?
  end

  test "scope is all users for admin and only self for a user" do
    assert_equal User.order(:id), UserPolicy::Scope.new(@admin, User).resolve.order(:id)
    assert_equal [ @player_one ], UserPolicy::Scope.new(@player_one, User).resolve.to_a
  end
end
