require "test_helper"

class SharePolicyTest < ActiveSupport::TestCase
  class ShareableTestDocument < ApplicationRecord
    include Shareable
  end

  setup do
    ActiveRecord::Base.connection.create_table :shareable_test_documents, force: true do |t|
      t.string :title
    end
    ShareableTestDocument.reset_column_information

    Current.session = users(:player_one).sessions.create!
    @document = ShareableTestDocument.create!(title: "Notes")
    @share = Share.new(shareable: @document, user: users(:player_two), access: :viewer)
  end

  teardown do
    ActiveRecord::Base.connection.drop_table :shareable_test_documents, if_exists: true
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

  test "owner cannot update or destroy an owner share" do
    owner_share = @document.shares.find_by!(user: users(:player_one), access: :owner)
    policy = SharePolicy.new(users(:player_one), owner_share)

    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "admin cannot update or destroy an owner share" do
    owner_share = @document.shares.find_by!(user: users(:player_one), access: :owner)
    policy = SharePolicy.new(users(:admin), owner_share)

    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "neither admin or owner can create an owner share" do
    owner_share = Share.new(shareable: @document, user: users(:player_two), access: :owner)

    assert_not SharePolicy.new(users(:player_one), owner_share).create?
    assert_not SharePolicy.new(users(:admin), owner_share).create?
  end

  test "neither admin or owner can promote a share to owner" do
    share = @document.shares.create!(user: users(:player_two), access: :viewer)
    share.assign_attributes(access: :owner)

    assert_not SharePolicy.new(users(:player_one), share).update?
    assert_not SharePolicy.new(users(:admin), share).update?
  end
end
