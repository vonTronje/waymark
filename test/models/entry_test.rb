require "test_helper"

class EntryTest < ActiveSupport::TestCase
  setup do
    Current.session = users(:player_one).sessions.create!
  end

  teardown do
    Current.session = nil
  end

  test "requires a title" do
    entry = Entry.new(description: "Some notes")

    assert_not entry.valid?
    assert_includes entry.errors[:title], "can't be blank"
  end

  test "accepts a rich text description" do
    entry = Entry.create!(title: "Character notes", description: "<div>Hello <strong>world</strong></div>")

    assert_equal "Hello world", entry.description.to_plain_text
  end

  test "creating an entry grants the current user an owner share" do
    entry = Entry.create!(title: "Character notes", description: "Details")

    assert entry.accessible_to?(users(:player_one), as: :owner)
    assert_not entry.accessible_to?(users(:player_two), as: :viewer)
  end
end
