require "test_helper"

class ShareTest < ActiveSupport::TestCase
  test "viewable includes viewer, editor, and owner" do
    assert_includes Share.viewable.to_sql, "IN ('viewer', 'editor', 'owner')"
  end

  test "editable includes editor and owner" do
    assert_includes Share.editable.to_sql, "IN ('editor', 'owner')"
  end

  test "owned includes only owner" do
    assert_includes Share.owned.to_sql, "\"access\" = 'owner'"
  end
end
