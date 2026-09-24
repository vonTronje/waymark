require "test_helper"

class AuthorizableTest < ActiveSupport::TestCase
  class AuthorizableTestDocument < ApplicationRecord
    include Authorizable
  end

  setup do
    ActiveRecord::Base.connection.create_table :authorizable_test_documents, force: true do |t|
      t.string :title
    end
    AuthorizableTestDocument.reset_column_information

    Current.session = users(:player_one).sessions.create!
  end

  teardown do
    ActiveRecord::Base.connection.drop_table :authorizable_test_documents, if_exists: true
  end

  test "creator has owner access to created object" do
    document = AuthorizableTestDocument.create!(title: "Notes")

    assert document.accessible_to?(users(:player_one), as: :owner)
    assert_not document.accessible_to?(users(:player_two), as: :viewer)
  end

  test "admin can access any record" do
    document = AuthorizableTestDocument.create!(title: "Notes")

    assert document.accessible_to?(users(:admin), as: :owner)
  end

  test "viewer share allows read but not edit" do
    document = AuthorizableTestDocument.create!(title: "Notes")
    document.shares.create!(user: users(:player_two), access: :viewer)

    assert document.accessible_to?(users(:player_two), as: :viewer)
    assert_not document.accessible_to?(users(:player_two), as: :editor)
  end

  test "editor share allows edit but not ownership" do
    document = AuthorizableTestDocument.create!(title: "Notes")
    document.shares.create!(user: users(:player_two), access: :editor)

    assert document.accessible_to?(users(:player_two), as: :editor)
    assert_not document.accessible_to?(users(:player_two), as: :owner)
  end

  test "accessible_to scope filters by share level" do
    shared = AuthorizableTestDocument.create!(title: "Shared")
    other = AuthorizableTestDocument.create!(title: "other")
    shared.shares.create!(user: users(:player_two), access: :viewer)

    assert_empty AuthorizableTestDocument.accessible_to(users(:player_two), as: :editor)
    assert_equal [ shared ], AuthorizableTestDocument.accessible_to(users(:player_two), as: :viewer).to_a
    assert_equal [ shared, other ], AuthorizableTestDocument.accessible_to(users(:admin)).order(:id)
  end

  test "access_for returns the users share access" do
    document = AuthorizableTestDocument.create!(title: "Notes")
    document.shares.create!(user: users(:player_two), access: :editor)

    assert_equal "owner", document.access_for(users(:player_one))
    assert_equal "editor", document.access_for(users(:player_two))
    assert_nil document.access_for(users(:game_master))
  end

  test "non_owner_access returns viewer and editor shares only" do
    document = AuthorizableTestDocument.create!(title: "Notes")
    viewer_share = document.shares.create!(user: users(:player_two), access: :viewer)
    editor_share = document.shares.create!(user: users(:game_master), access: :editor)

    assert_equal [ viewer_share, editor_share ].sort_by(&:id), document.non_owner_access.order(:id).to_a
  end
end
