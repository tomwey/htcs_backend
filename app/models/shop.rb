class Shop < ActiveRecord::Base
  validates :name, :address, presence: true
  
  acts_as_mappable
  
  before_create :generate_uniq_id
  def generate_uniq_id
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.uniq_id = (n.to_s + SecureRandom.random_number.to_s[2..6]).to_i
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  before_save :parse_location
  def parse_location
    if address.blank?
      return true
    end
    
    loc = ParseLocation.start(address)
    if loc.blank?
      errors.add(:base, '位置不正确或者解析出错')
      return false
    end
    
    lat,lng = loc
    self.lat = lat
    self.lng = lng
    
  end
end
