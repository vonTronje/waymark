require "test_helper"

# Behavior is tested with Entry as an example Shareable, but the type of Shareable does not matter.
class SharesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @player_one = users(:player_one)
    @player_two = users(:player_two)
    @shareable = entries(:player_one_character_notes)
    sign_in_as @player_one
  end

  test "owner can create a viewer share" do
    assert_difference("Share.count") do
      post entry_shares_url(@shareable), params: {
        share: { user_id: @player_two.id, access: "viewer" }
      }
    end

    assert_redirected_to entry_url(@shareable)
    share = Share.find_by!(shareable: @shareable, user: @player_two)
    assert share.viewer?
  end

  test "owner can create an editor share" do
    assert_difference("Share.count") do
      post entry_shares_url(@shareable), params: {
        share: { user_id: @player_two.id, access: "editor" }
      }
    end

    assert_redirected_to entry_url(@shareable)
    share = Share.find_by!(shareable: @shareable, user: @player_two)
    assert share.editor?
  end

  test "owner cannot create an owner share" do
    assert_no_difference("Share.count") do
      post entry_shares_url(@shareable), params: {
        share: { user_id: @player_two.id, access: "owner" }
      }
    end

    assert_redirected_to user_path(@player_one)
  end

  test "viewer cannot create a share" do
    shareable = entries(:player_one_shared_view)
    sign_in_as @player_two

    assert_no_difference("Share.count") do
      post entry_shares_url(shareable), params: {
        share: { user_id: users(:game_master).id, access: "viewer" }
      }
    end

    assert_redirected_to user_path(@player_two)
  end

  test "owner can update a share between viewer and editor" do
    shareable = entries(:player_one_shared_view)
    share = shares(:player_two_shared_view_viewer)

    patch entry_share_url(shareable, share), params: { share: { access: "editor" } }

    assert_redirected_to entry_url(shareable)
    assert share.reload.editor?
  end

  test "owner cannot promote a share to owner" do
    shareable = entries(:player_one_shared_view)
    share = shares(:player_two_shared_view_viewer)

    patch entry_share_url(shareable, share), params: { share: { access: "owner" } }

    assert_redirected_to user_path(@player_one)
    assert share.reload.viewer?
  end

  test "owner can destroy a non-owner share" do
    shareable = entries(:player_one_shared_view)
    share = shares(:player_two_shared_view_viewer)

    assert_difference("Share.count", -1) do
      delete entry_share_url(shareable, share)
    end

    assert_redirected_to entry_url(shareable)
  end

  test "owner cannot destroy an owner share" do
    share = shares(:player_one_character_notes_owner)

    assert_no_difference("Share.count") do
      delete entry_share_url(@shareable, share)
    end

    assert_redirected_to user_path(@player_one)
  end

  test "viewer cannot destroy a share" do
    shareable = entries(:player_one_shared_view)
    share = shares(:player_two_shared_view_viewer)
    sign_in_as @player_two

    assert_no_difference("Share.count") do
      delete entry_share_url(shareable, share)
    end

    assert_redirected_to user_path(@player_two)
  end
end
