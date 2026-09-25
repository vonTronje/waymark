require "test_helper"

class CharactersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @player_one = users(:player_one)
    @player_two = users(:player_two)
    @game_master = users(:game_master)
    sign_in_as @player_one
    @character = characters(:player_one_character)
  end

  test "index lists only accessible characters" do
    get characters_url

    assert_response :success
    assert_select "div#characters" do
      assert_select "a", text: "Aria Stormwind"
      assert_select "a", text: "Village Guide"
      assert_select "a", text: "Borin Ironfist", count: 0
      assert_select "a", text: "Hidden Assassin", count: 0
    end
  end

  test "can get new" do
    get new_character_url

    assert_response :success
  end

  test "can create a character" do
    assert_difference("Character.count") do
      post characters_url, params: {
        character: {
          name: "New Hero",
          level: 2,
          character_class: "Bard",
          species: "Gnome"
        }
      }
    end

    character = Character.last
    assert_redirected_to character_url(character)
    assert character.accessible_to?(@player_one, as: :owner)
  end

  test "owner can show a character" do
    get character_url(@character)

    assert_response :success
  end

  test "owner can get edit" do
    get edit_character_url(@character)

    assert_response :success
  end

  test "owner can update a character" do
    patch character_url(@character), params: {
      character: { name: "Updated Aria", level: 6 }
    }

    assert_redirected_to character_url(@character)
    @character.reload
    assert_equal "Updated Aria", @character.name
    assert_equal 6, @character.level
  end

  test "owner can destroy a character" do
    assert_difference("Character.count", -1) do
      delete character_url(@character)
    end

    assert_redirected_to characters_url
  end

  test "editor can edit a character" do
    sign_in_as @game_master

    get edit_character_url(@character)

    assert_response :success
  end

  test "editor can update a character" do
    sign_in_as @game_master

    patch character_url(@character), params: {
      character: { name: "Edited by editor", level: 5 }
    }

    assert_redirected_to character_url(@character)
    @character.reload
    assert_equal "Edited by editor", @character.name
    assert_equal 5, @character.level
  end

  test "editor cannot destroy a character" do
    sign_in_as @game_master

    assert_no_difference("Character.count") do
      delete character_url(@character)
    end

    assert_redirected_to user_path(@game_master)
  end

  test "viewer can show a character" do
    get character_url(characters(:npc_one))

    assert_response :success
  end

  test "viewer cannot edit a character" do
    get edit_character_url(characters(:npc_one))

    assert_redirected_to user_path(@player_one)
  end

  test "viewer cannot update a character" do
    character = characters(:npc_one)

    patch character_url(character), params: { character: { name: "Hacked" } }

    assert_redirected_to user_path(@player_one)
    assert_equal "Village Guide", character.reload.name
  end

  test "unrelated user cannot show a character" do
    sign_in_as @player_two

    get character_url(@character)

    assert_redirected_to user_path(@player_two)
  end
end
