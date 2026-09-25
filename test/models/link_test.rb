require "test_helper"

class LinkTest < ActiveSupport::TestCase
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
    @source = LinkableTestDocument.create!(title: "Source")
    @target = LinkableTestDocument.create!(title: "Target")
  end

  teardown do
    Linkable.registry.delete(LinkableTestDocument)
    ActiveRecord::Base.connection.drop_table :linkable_test_documents, if_exists: true
    Current.session = nil
  end

  test "requires a known link_type" do
    assert_raises(ArgumentError) do
      Link.new(source: @source, target: @target, link_type: :unknown)
    end
  end

  test "accepts mention, author, and owner link types" do
    %i[mention author owner].each do |link_type|
      link = Link.new(source: @source, target: @target, link_type: link_type)
      assert link.valid?, "expected #{link_type} to be valid"
    end
  end

  test "allows optional note and occurred_on" do
    link = Link.create!(
      source: @source,
      target: @target,
      link_type: :mention,
      note: "First meeting",
      occurred_on: Date.new(1480, 3, 15)
    )

    assert_equal "First meeting", link.note
    assert_equal Date.new(1480, 3, 15), link.occurred_on
  end

  test "rejects non-linkable source or target" do
    link = Link.new(source: users(:player_one), target: @target, link_type: :mention)

    assert_not link.valid?
    assert_includes link.errors[:source], "must be a linkable type"
  end

  test "rejects self-links" do
    link = Link.new(source: @source, target: @source, link_type: :mention)

    assert_not link.valid?
    assert_includes link.errors[:target], "must be different from source"
  end

  test "allows multiple links of the same type between the same pair" do
    assert_difference("Link.count", 2) do
      Link.create!(source: @source, target: @target, link_type: :mention)
      Link.create!(source: @source, target: @target, link_type: :mention)
    end
  end

  test "involving returns links where the record is source or target" do
    outgoing = Link.create!(source: @source, target: @target, link_type: :mention)
    incoming = Link.create!(source: @target, target: @source, link_type: :author)

    other_source = LinkableTestDocument.create!(title: "Other source")
    Link.create!(source: other_source, target: @target, link_type: :owner)

    assert_equal [ outgoing, incoming ].sort_by(&:id), Link.involving(@source).order(:id).to_a
  end
end
