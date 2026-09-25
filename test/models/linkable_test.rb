require "test_helper"

class LinkableTest < ActiveSupport::TestCase
  class LinkableTestDocument < ApplicationRecord
    def self.skip_shareable_registration? = true
    include Shareable
    include Linkable
  end

  setup do
    ActiveRecord::Base.connection.create_table :linkable_test_documents, force: true do |t|
      t.string :title
    end
    LinkableTestDocument.reset_column_information

    Current.session = users(:player_one).sessions.create!
    @document = LinkableTestDocument.create!(title: "Notes")
    @other = LinkableTestDocument.create!(title: "Other")
  end

  teardown do
    Linkable.registry.delete(LinkableTestDocument)
    ActiveRecord::Base.connection.drop_table :linkable_test_documents, if_exists: true
    Current.session = nil
  end

  test "Entry and Character are registered as linkable" do
    Rails.application.eager_load! unless Rails.application.config.eager_load

    assert_includes Linkable.registry, Entry
    assert_includes Linkable.registry, Character
    assert_not_includes Linkable.registry, User
  end

  test "has outgoing and incoming links" do
    link = Link.create!(source: @document, target: @other, link_type: :mention)

    assert_includes @document.outgoing_links, link
    assert_includes @other.incoming_links, link
  end

  test "links returns outgoing and incoming links" do
    outgoing = Link.create!(source: @document, target: @other, link_type: :mention)
    incoming = Link.create!(source: @other, target: @document, link_type: :author)

    assert_equal [ outgoing, incoming ].sort_by(&:id), @document.links.order(:id).to_a
  end

  test "destroying a linkable destroys related links" do
    Link.create!(source: @document, target: @other, link_type: :mention)
    Link.create!(source: @other, target: @document, link_type: :author)

    assert_difference("Link.count", -2) do
      @document.destroy!
    end
  end
end
