require "test_helper"

class CharacterTest < ActiveSupport::TestCase
  setup do
    Current.session = users(:player_one).sessions.create!
  end

  teardown do
    Current.session = nil
  end

  test "requires name, level, character_class, and species" do
    character = Character.new

    assert_not character.valid?
    assert_includes character.errors[:name], "can't be blank"
    assert_includes character.errors[:level], "can't be blank"
    assert_includes character.errors[:character_class], "can't be blank"
    assert_includes character.errors[:species], "can't be blank"
  end

  test "creating a character grants the current user an owner share" do
    character = Character.create!(
      name: "Aria",
      level: 1,
      character_class: "Wizard",
      species: "Elf"
    )

    assert character.accessible_to?(users(:player_one), as: :owner)
    assert_not character.accessible_to?(users(:player_two), as: :viewer)
  end

  test "can attach an image" do
    character = characters(:player_one_character)
    character.image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/avatar.png")),
      filename: "avatar.png",
      content_type: "image/png"
    )

    assert character.image.attached?
  end
end
