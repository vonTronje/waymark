require "test_helper"

# Behavior is tested with Entry as an example Linkable.
class LinkTest < ActiveSupport::TestCase
  setup do
    @one = entries(:player_one_character_notes)
    @two = entries(:player_one_shared_view)
  end

  test "requires a known link_type" do
    assert_raises(ArgumentError) do
      Link.new(source: @one, target: @two, link_type: :unknown)
    end
  end

  test "accepts mention, author, and owner link types" do
    %i[mention author owner].each do |link_type|
      link = Link.new(source: @one, target: @two, link_type: link_type)
      assert link.valid?, "expected #{link_type} to be valid"
    end
  end

  test "allows optional note and occurred_on" do
    link = Link.create!(
      source: @one,
      target: @two,
      link_type: :mention,
      note: "First meeting",
      occurred_on: Date.new(1480, 3, 15)
    )

    assert_equal "First meeting", link.note
    assert_equal Date.new(1480, 3, 15), link.occurred_on
  end

  test "rejects non-linkable source or target" do
    link = Link.new(source: users(:player_one), target: @two, link_type: :mention)

    assert_not link.valid?
    assert_includes link.errors[:source], "must be a linkable type"
  end

  test "rejects self-links" do
    link = Link.new(source: @one, target: @one, link_type: :mention)

    assert_not link.valid?
    assert_includes link.errors[:target], "must be different from source"
  end

  test "allows multiple links of the same type between the same pair" do
    assert_difference("Link.count", 2) do
      Link.create!(source: @one, target: @two, link_type: :mention)
      Link.create!(source: @one, target: @two, link_type: :mention)
    end
  end

  test "involving returns links where the record is source or target" do
    outgoing = Link.create!(source: @one, target: @two, link_type: :mention)
    incoming = Link.create!(source: @two, target: @one, link_type: :author)
    three = entries(:player_two_secret)
    Link.create!(source: three, target: @two, link_type: :owner)

    assert_equal [ outgoing, incoming ].sort_by(&:id), Link.involving(@one).order(:id).to_a
  end
end
