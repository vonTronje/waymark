require "test_helper"

class EntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @player_one = users(:player_one)
    @player_two = users(:player_two)
    sign_in_as @player_one
    @entry = entries(:player_one_character_notes)
  end

  test "index lists only accessible entries" do
    get entries_url

    assert_response :success
    assert_select "div#entries" do
      assert_select "a", text: "Character notes"
      assert_select "a", text: "Shared view notes"
      assert_select "a", text: "Shared edit notes"
      assert_select "a", text: "Secret", count: 0
    end
  end

  test "owner can show an entry" do
    get entry_url(@entry)

    assert_response :success
    assert_select "h1", text: "Character notes"
  end

  test "viewer can show an entry" do
    sign_in_as @player_two

    get entry_url(entries(:player_one_shared_view))

    assert_response :success
  end

  test "unrelated user cannot show an entry" do
    sign_in_as @player_two

    get entry_url(@entry)

    assert_redirected_to user_path(@player_two)
  end

  test "can get new" do
    get new_entry_url

    assert_response :success
  end

  test "can create an entry" do
    assert_difference("Entry.count") do
      post entries_url, params: { entry: { title: "New entry", description: "Rich text" } }
    end

    entry = Entry.last
    assert_redirected_to entry_url(entry)
    assert entry.accessible_to?(@player_one, as: :owner)
    assert_equal "Rich text", entry.description.to_plain_text
  end

  test "owner can get edit" do
    get edit_entry_url(@entry)

    assert_response :success
  end

  test "viewer cannot get edit" do
    sign_in_as @player_two

    get edit_entry_url(entries(:player_one_shared_view))

    assert_redirected_to user_path(@player_two)
  end

  test "editor can get edit" do
    sign_in_as @player_two

    get edit_entry_url(entries(:player_one_shared_edit))

    assert_response :success
  end

  test "owner can update an entry" do
    patch entry_url(@entry), params: { entry: { title: "Updated", description: "Changed" } }

    assert_redirected_to entry_url(@entry)
    @entry.reload
    assert_equal "Updated", @entry.title
    assert_equal "Changed", @entry.description.to_plain_text
  end

  test "viewer cannot update an entry" do
    entry = entries(:player_one_shared_view)
    sign_in_as @player_two

    patch entry_url(entry), params: { entry: { title: "Hacked" } }

    assert_redirected_to user_path(@player_two)
    assert_equal "Shared view notes", entry.reload.title
  end

  test "owner can destroy an entry" do
    assert_difference("Entry.count", -1) do
      delete entry_url(@entry)
    end

    assert_redirected_to entries_url
  end

  test "editor cannot destroy an entry" do
    entry = entries(:player_one_shared_edit)
    sign_in_as @player_two

    assert_no_difference("Entry.count") do
      delete entry_url(entry)
    end

    assert_redirected_to user_path(@player_two)
  end
end
