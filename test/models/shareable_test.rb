require "test_helper"

# Behavior is tested with Entry as an example Shareable.
class ShareableTest < ActiveSupport::TestCase
  setup do
    Current.session = users(:player_one).sessions.create!
  end

  teardown do
    Current.session = nil
  end

  test "creator has owner access to created object" do
    shareable = Entry.create!(title: "Notes")

    assert shareable.accessible_to?(users(:player_one), as: :owner)
    assert_not shareable.accessible_to?(users(:player_two), as: :viewer)
  end

  test "admin can access any record" do
    shareable = entries(:player_two_secret)

    assert shareable.accessible_to?(users(:admin), as: :owner)
  end

  test "viewer share allows read but not edit" do
    shareable = entries(:player_one_shared_view)

    assert shareable.accessible_to?(users(:player_two), as: :viewer)
    assert_not shareable.accessible_to?(users(:player_two), as: :editor)
  end

  test "editor share allows edit but not ownership" do
    shareable = entries(:player_one_shared_edit)

    assert shareable.accessible_to?(users(:player_two), as: :editor)
    assert_not shareable.accessible_to?(users(:player_two), as: :owner)
  end

  test "accessible_to scope includes records visible as viewer" do
    as_viewer = Entry.accessible_to(users(:player_two), as: :viewer)

    assert_includes as_viewer, entries(:player_one_shared_view)
    assert_includes as_viewer, entries(:player_one_shared_edit)
    assert_includes as_viewer, entries(:player_two_secret)
    assert_not_includes as_viewer, entries(:player_one_character_notes)
  end

  test "accessible_to scope includes records editable as editor" do
    as_editor = Entry.accessible_to(users(:player_two), as: :editor)

    assert_includes as_editor, entries(:player_one_shared_edit)
    assert_includes as_editor, entries(:player_two_secret)
    assert_not_includes as_editor, entries(:player_one_shared_view)
  end

  test "accessible_to scope includes all records for admin" do
    as_admin = Entry.accessible_to(users(:admin))

    assert_includes as_admin, entries(:player_one_character_notes)
    assert_includes as_admin, entries(:player_two_secret)
  end

  test "access_for returns the users share access" do
    shareable = entries(:player_one_shared_edit)

    assert_equal "owner", shareable.access_for(users(:player_one))
    assert_equal "editor", shareable.access_for(users(:player_two))
    assert_nil shareable.access_for(users(:game_master))
  end

  test "non_owner_access returns viewer and editor shares only" do
    shareable = entries(:player_one_character_notes)
    viewer_share = shareable.shares.create!(user: users(:player_two), access: :viewer)
    editor_share = shareable.shares.create!(user: users(:game_master), access: :editor)

    assert_equal [ viewer_share, editor_share ].sort_by(&:id), shareable.non_owner_access.order(:id).to_a
  end
end
