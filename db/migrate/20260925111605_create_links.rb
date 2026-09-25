class CreateLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :links do |t|
      t.references :source, polymorphic: true, null: false
      t.references :target, polymorphic: true, null: false
      t.string :link_type, null: false
      t.text :note
      t.date :occurred_on

      t.timestamps
    end
  end
end
