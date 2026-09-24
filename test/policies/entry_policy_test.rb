require "test_helper"

class EntryPolicyTest < ActiveSupport::TestCase
  setup do
    @entry = Entry.create!(title: "Character notes", description: "Details")
  end

  test "user can index and create" do
    policy = EntryPolicy.new(users(:player_one), Entry)

    assert policy.index?
    assert policy.create?
  end

  test "owner can show, update, and destroy" do
    @entry.shares.create!(user: users(:player_one), access: :owner)
    policy = EntryPolicy.new(users(:player_one), @entry)

    assert policy.show?
    assert policy.update?
    assert policy.destroy?
  end

  test "viewer can show but not update or destroy" do
    @entry.shares.create!(user: users(:player_two), access: :viewer)
    policy = EntryPolicy.new(users(:player_two), @entry)

    assert policy.show?
    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "editor can show and update but not destroy" do
    @entry.shares.create!(user: users(:player_two), access: :editor)
    policy = EntryPolicy.new(users(:player_two), @entry)

    assert policy.show?
    assert policy.update?
    assert_not policy.destroy?
  end

  test "unrelated user cannot show, update, or destroy" do
    policy = EntryPolicy.new(users(:player_two), @entry)

    assert_not policy.show?
    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "admin can show, update, and destroy any entry" do
    policy = EntryPolicy.new(users(:admin), @entry)

    assert policy.show?
    assert policy.update?
    assert policy.destroy?
  end

  test "scope includes accessible entries for a user and all for admin" do
    accessible_to_player_two = [
      entries(:player_one_shared_view),
      entries(:player_one_shared_edit),
      entries(:player_two_secret)
    ]

    assert_equal accessible_to_player_two.sort_by(&:id),
                 EntryPolicy::Scope.new(users(:player_two), Entry).resolve.order(:id).to_a
    assert_equal Entry.order(:id).to_a,
                 EntryPolicy::Scope.new(users(:admin), Entry).resolve.order(:id).to_a
  end
end
