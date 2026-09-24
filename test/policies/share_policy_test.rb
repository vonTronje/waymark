require "test_helper"

class SharePolicyTest < ActiveSupport::TestCase
  class AuthorizableTestDocument < ApplicationRecord
    include Authorizable
  end

  setup do
    ActiveRecord::Base.connection.create_table :authorizable_test_documents, force: true do |t|
      t.string :title
    end
    AuthorizableTestDocument.reset_column_information

    Current.session = users(:player_one).sessions.create!
    @document = AuthorizableTestDocument.create!(title: "Notes")
    @share = Share.new(shareable: @document, user: users(:player_two), access: :viewer)
  end

  teardown do
    ActiveRecord::Base.connection.drop_table :authorizable_test_documents, if_exists: true
  end

  test "owner can create, update, and destroy shares" do
    policy = SharePolicy.new(users(:player_one), @share)

    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end

  test "viewer cannot create, update, or destroy shares" do
    @document.shares.create!(user: users(:player_two), access: :viewer)
    policy = SharePolicy.new(users(:player_two), @share)

    assert_not policy.create?
    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "editor cannot create, update, or destroy shares" do
    @document.shares.create!(user: users(:player_two), access: :editor)
    policy = SharePolicy.new(users(:player_two), @share)

    assert_not policy.create?
    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "admin can create, update, and destroy shares" do
    policy = SharePolicy.new(users(:admin), @share)

    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end
end
