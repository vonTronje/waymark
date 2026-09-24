require "test_helper"

class SharesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @player_one = users(:player_one)
    @player_two = users(:player_two)
    @entry = entries(:player_one_character_notes)
    sign_in_as @player_one
  end

  test "owner can create a viewer share" do
    assert_difference("Share.count") do
      post entry_shares_url(@entry), params: {
        share: { user_id: @player_two.id, access: "viewer" }
      }
    end

    assert_redirected_to entry_url(@entry)
    share = Share.find_by!(shareable: @entry, user: @player_two)
    assert share.viewer?
  end

  test "owner can create an editor share" do
    assert_difference("Share.count") do
      post entry_shares_url(@entry), params: {
        share: { user_id: @player_two.id, access: "editor" }
      }
    end

    assert_redirected_to entry_url(@entry)
    share = Share.find_by!(shareable: @entry, user: @player_two)
    assert share.editor?
  end

  test "owner cannot create an owner share" do
    assert_no_difference("Share.count") do
      post entry_shares_url(@entry), params: {
        share: { user_id: @player_two.id, access: "owner" }
      }
    end

    assert_redirected_to user_path(@player_one)
  end

  test "viewer cannot create a share" do
    entry = entries(:player_one_shared_view)
    sign_in_as @player_two

    assert_no_difference("Share.count") do
      post entry_shares_url(entry), params: {
        share: { user_id: users(:game_master).id, access: "viewer" }
      }
    end

    assert_redirected_to user_path(@player_two)
  end

  test "owner can update a share between viewer and editor" do
    entry = entries(:player_one_shared_view)
    share = shares(:player_two_shared_view_viewer)

    patch entry_share_url(entry, share), params: { share: { access: "editor" } }

    assert_redirected_to entry_url(entry)
    assert share.reload.editor?
  end

  test "owner cannot promote a share to owner" do
    entry = entries(:player_one_shared_view)
    share = shares(:player_two_shared_view_viewer)

    patch entry_share_url(entry, share), params: { share: { access: "owner" } }

    assert_redirected_to user_path(@player_one)
    assert share.reload.viewer?
  end

  test "owner can destroy a non-owner share" do
    entry = entries(:player_one_shared_view)
    share = shares(:player_two_shared_view_viewer)

    assert_difference("Share.count", -1) do
      delete entry_share_url(entry, share)
    end

    assert_redirected_to entry_url(entry)
  end

  test "owner cannot destroy an owner share" do
    share = shares(:player_one_character_notes_owner)

    assert_no_difference("Share.count") do
      delete entry_share_url(@entry, share)
    end

    assert_redirected_to user_path(@player_one)
  end

  test "viewer cannot destroy a share" do
    entry = entries(:player_one_shared_view)
    share = shares(:player_two_shared_view_viewer)
    sign_in_as @player_two

    assert_no_difference("Share.count") do
      delete entry_share_url(entry, share)
    end

    assert_redirected_to user_path(@player_two)
  end
end
