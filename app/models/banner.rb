class Banner < ActiveRecord::Base
  validates :image, :page_types, presence: true
  mount_uploader :image, BannerImageUploader
  
  scope :opened, -> { where(opened: true) }
  scope :sorted, -> { order('sort desc') }
  
  before_create :generate_uid_and_private_token
  def generate_uid_and_private_token
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.uniq_id = (n.to_s + SecureRandom.random_number.to_s[2..6]).to_i
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  before_save :remove_blank_value_for_array
  def remove_blank_value_for_array
    self.page_types = self.page_types.compact.reject(&:blank?)
  end
  
  def is_link?
    self.link && (self.link.start_with?('http://') or self.link.start_with?('https://'))
  end
  
  def loan_product
    _,id = self.link.split(':')
    @product ||= LoanProduct.find_by(uniq_id: id)
  end
  
  def page
    _,id = self.link.split(':')
    @product ||= Page.find_by(slug: id)
  end
  
  def is_page?
    self.link && self.link.start_with?('page:')
  end
  
  def is_loan_product?
    self.link && (self.link.start_with?('loan:') or self.link.start_with?('product:'))
  end
  
  # def is_vote?
  #   self.link && self.link.start_with?('vote://')
  # end
  #
  # def is_media?
  #   self.link && self.link.start_with?('media://')
  # end
  #
  # def vote
  #   if self.is_vote?
  #     _,id = self.link.split('id=')
  #     @vote ||= Vote.find_by(uniq_id: id)
  #   else
  #     nil
  #   end
  # end
  #
  # def media
  #   if self.is_media?
  #     _,id = self.link.split('id=')
  #     @media ||= Media.find_by(uniq_id: id)
  #   else
  #     nil
  #   end
  # end
  
end
