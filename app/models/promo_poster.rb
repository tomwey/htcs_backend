class PromoPoster < ActiveRecord::Base
  validates :name, :top_img, presence: true
  mount_uploader :top_img, PosterUploader
  mount_uploader :bottom_img, PosterUploader
  
  belongs_to :loan_product, foreign_key: :product_id
  
  before_create :generate_unique_id
  def generate_unique_id
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.uniq_id = (n.to_s + SecureRandom.random_number.to_s[2..6]).to_i
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
end

# t.integer :product_id, null: false
# t.string :top_img
# t.string :bottom_img
# t.string :bg_color
# t.string :btn_text
# t.string :app_url
# t.boolean :opened, default: true
