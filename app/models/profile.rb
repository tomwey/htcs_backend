class Profile < ActiveRecord::Base
  belongs_to :user
  validates :name, :sex, :idcard, presence: true
  validates :idcard, format: { with: /\A\d{6}(18|19|20)?\d{2}(0[1-9]|1[012])(0[1-9]|[12]\d|3[01])\d{3}(\d|[xX])\z/, message: '不正确' }
  
  default_scope -> { where(visible: true).order('id desc') }
  
  def payed_salary
    return '--' if user.blank?
    
    Salary.where(user_id: user.id).where.not(payed_at: nil).sum(:money)
  end
  
  def unpayed_salary
    return '--' if user.blank?
    Salary.where(user_id: user.id).where(payed_at: nil).sum(:money)
  end
  
  def delete!
    self.visible = false;
    self.save!(validate: false)
  end
  
end
