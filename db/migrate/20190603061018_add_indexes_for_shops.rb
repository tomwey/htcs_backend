class AddIndexesForShops < ActiveRecord::Migration
  def self.up
    add_index :shops, [:lat, :lng]
  end
  def self.down
    remove_index :shops, [:lat, :lng]
  end
end
