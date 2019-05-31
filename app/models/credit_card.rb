class CreditCard < ActiveRecord::Base
  validates :cover, :bank_id, :name, :apply_url, presence: true
  belongs_to :bank
  mount_uploader :cover, CreditCardUploader
end

# t.integer :bank_id, null: false
# t.string :cover, null: false
# t.string :name, null: false
# t.string :intro
# t.string :special
# t.string :apply_url, null: false
# t.integer :view_count, default: 0
# t.integer :sort, default: 0
# t.integer :apply_count, default: 0
# t.boolean :opened, default: true
