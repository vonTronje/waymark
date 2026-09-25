require "test_helper"

class CharacterPolicyTest < ActiveSupport::TestCase
  test "user can index and create" do
    policy = CharacterPolicy.new(users(:player_one), Character)

    assert policy.index?
    assert policy.create?
  end

  test "owner can show, update, and destroy" do
    policy = CharacterPolicy.new(users(:player_one), characters(:player_one_character))

    assert policy.show?
    assert policy.update?
    assert policy.destroy?
  end

  test "viewer can show but not update or destroy" do
    policy = CharacterPolicy.new(users(:player_one), characters(:npc_one))

    assert policy.show?
    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "editor can show and update but not destroy" do
    policy = CharacterPolicy.new(users(:game_master), characters(:player_one_character))

    assert policy.show?
    assert policy.update?
    assert_not policy.destroy?
  end

  test "unrelated user cannot show, update, or destroy" do
    policy = CharacterPolicy.new(users(:player_two), characters(:player_one_character))

    assert_not policy.show?
    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "admin can show, update, and destroy any character" do
    policy = CharacterPolicy.new(users(:admin), characters(:npc_secret))

    assert policy.show?
    assert policy.update?
    assert policy.destroy?
  end

  test "admin can share a character" do
    assert CharacterPolicy.new(users(:admin), characters(:npc_secret)).share?
  end

  test "owner can share a character" do
    assert CharacterPolicy.new(users(:player_one), characters(:player_one_character)).share?
  end

  test "viewer cannot share a character" do
    assert_not CharacterPolicy.new(users(:player_one), characters(:npc_one)).share?
  end

  test "editor cannot share a character" do
    assert_not CharacterPolicy.new(users(:game_master), characters(:player_one_character)).share?
  end

  test "scope includes accessible characters for a user" do
    accessible_to_player_one = [
      characters(:player_one_character),
      characters(:npc_one)
    ]

    assert_equal accessible_to_player_one.sort_by(&:id),
                 CharacterPolicy::Scope.new(users(:player_one), Character).resolve.order(:id).to_a
  end

  test "scope includes all characters for admin" do
    assert_equal Character.order(:id).to_a,
                 CharacterPolicy::Scope.new(users(:admin), Character).resolve.order(:id).to_a
  end
end
