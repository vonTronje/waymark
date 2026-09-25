class CreateCharacters < ActiveRecord::Migration[8.1]
  def change
    create_table :characters do |t|
      t.string :name, null: false
      t.integer :level, null: false
      t.string :character_class, null: false
      t.string :species, null: false

      t.timestamps
    end
  end
end
