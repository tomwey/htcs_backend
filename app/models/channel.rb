class Channel < ActiveRecord::Base
  validates :name, :poster_id, presence: true
  belongs_to :promo_poster, foreign_key: :poster_id
  
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
  
  def share_url
    ShortUrl.sina("#{SiteConfig.base_url}/channel/#{self.uniq_id}")
  end
end
