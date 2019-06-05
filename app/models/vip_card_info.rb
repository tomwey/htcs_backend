class VipCardInfo < ActiveRecord::Base
  before_save :create_card_id
  def create_card_id
    if self.card_id.blank?
      begin
        self.card_id = create_str(6) + create_str(6)
      end while self.class.exists?(:card_id => card_id)
    end
  end
  
  private
  def create_str(len)
    n = rand(10)
    if n == 0
      n = 8
    end
    return (n.to_s + SecureRandom.random_number.to_s[2..len])
  end
end
