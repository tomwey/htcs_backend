class CreateVipCardInfos < ActiveRecord::Migration
  def change
    create_table :vip_card_infos do |t|
      t.string :vip_name
      t.string :mobile
      t.string :idcard
      t.string :card_id
      t.string :openid
      t.datetime :actived_at
      t.boolean :verified, default: true
      t.text :memo

      t.timestamps null: false
    end
    add_index :vip_card_infos, :card_id, unique: true
  end
end
