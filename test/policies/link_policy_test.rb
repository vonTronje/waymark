require "test_helper"

class LinkPolicyTest < ActiveSupport::TestCase
  setup do
    @source = entries(:player_one_shared_view)
    @visible_target = characters(:npc_one)
    @hidden_target = entries(:player_two_secret)

    @visible_link = Link.new(
      source: @source,
      target: @visible_target,
      link_type: :mention
    )
    @partial_link = Link.new(
      source: @source,
      target: @hidden_target,
      link_type: :mention
    )
  end

  test "viewer on both ends can show, create, update, and destroy" do
    # player_one: owner of shared_view, viewer of npc_one
    policy = LinkPolicy.new(users(:player_one), @visible_link)

    assert policy.show?
    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end

  test "viewer missing one end cannot show or mutate" do
    # player_one: owner of shared_view, no access to player_two_secret
    policy = LinkPolicy.new(users(:player_one), @partial_link)

    assert_not policy.show?
    assert_not policy.create?
    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "user with no access to either end cannot show or mutate" do
    link = Link.new(
      source: entries(:player_one_character_notes),
      target: characters(:player_one_character),
      link_type: :author
    )
    policy = LinkPolicy.new(users(:player_two), link)

    assert_not policy.show?
    assert_not policy.create?
    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "admin can show and mutate any link" do
    policy = LinkPolicy.new(users(:admin), @partial_link)

    assert policy.show?
    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end

  test "scope includes only links visible on both ends" do
    visible = Link.create!(source: @source, target: @visible_target, link_type: :mention)
    hidden = Link.create!(source: @source, target: @hidden_target, link_type: :author)

    resolved = LinkPolicy::Scope.new(users(:player_one), Link.all).resolve

    assert_includes resolved, visible
    assert_not_includes resolved, hidden
  end

  test "scope includes all links for admin" do
    visible = Link.create!(source: @source, target: @visible_target, link_type: :mention)
    hidden = Link.create!(source: @source, target: @hidden_target, link_type: :author)

    resolved = LinkPolicy::Scope.new(users(:admin), Link.all).resolve

    assert_includes resolved, visible
    assert_includes resolved, hidden
  end
end
