require "test_helper"

# Behavior is tested with Entry as an example Linkable; registry assertions cover other models.
class LinkableTest < ActiveSupport::TestCase
  setup do
    @one = entries(:player_one_character_notes)
    @two = entries(:player_one_shared_view)
  end

  test "Entry and Character are registered as linkable" do
    Rails.application.eager_load! unless Rails.application.config.eager_load

    assert_includes Linkable.registry, Entry
    assert_includes Linkable.registry, Character
    assert_not_includes Linkable.registry, User
  end

  test "has outgoing and incoming links" do
    link = Link.create!(source: @one, target: @two, link_type: :mention)

    assert_includes @one.outgoing_links, link
    assert_includes @two.incoming_links, link
  end

  test "links returns outgoing and incoming links" do
    outgoing = Link.create!(source: @one, target: @two, link_type: :mention)
    incoming = Link.create!(source: @two, target: @one, link_type: :author)

    assert_equal [ outgoing, incoming ].sort_by(&:id), @one.links.order(:id).to_a
  end

  test "destroying a linkable destroys related links" do
    Link.create!(source: @one, target: @two, link_type: :mention)
    Link.create!(source: @two, target: @one, link_type: :author)

    assert_difference("Link.count", -2) do
      @one.destroy!
    end
  end
end
