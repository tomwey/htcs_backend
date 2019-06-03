class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops do |t|
      t.integer :uniq_id
      t.string :name, null: false
      t.string :address, null: false
      t.string :lat
      t.string :lng
      t.boolean :opened, default: true
      t.integer :sort, default: 0

      t.timestamps null: false
    end
    add_index :shops, :uniq_id, unique: true
  end
end
