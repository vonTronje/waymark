class CreateShares < ActiveRecord::Migration[8.1]
  def change
    create_table :shares do |t|
      t.references :user, null: false, foreign_key: true
      t.references :shareable, null: false, polymorphic: true
      t.string :access, null: false

      t.timestamps
    end

    add_index :shares, [ :user_id, :shareable_type, :shareable_id ], unique: true
    add_index :shares, [ :shareable_type, :shareable_id ], unique: true, where: "access = 'owner'", name: "index_shares_one_owner"
  end
end
