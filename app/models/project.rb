class Project < ActiveRecord::Base
  validates :title, :begin_date, :end_date, presence: true
  
  has_many :salaries, dependent: :destroy
  
  default_scope -> { where(visible: true).order('id desc') }
  
  validate :check_date
  def check_date
    if begin_date > end_date
      errors.add(:begin_date, '开始日期不能大于截止日期')
    end
  end
  
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
  
  def confirm_pay!
    SendSalaryJob.perform_later(self.id)
  end
  
  def total_salary_money
    @mm ||= salaries.sum(:money)
  end
  
  def sent_salary_money
    @m2 ||= salaries.where.not(payed_at: nil).sum(:money)
  end
  
  def senting_salary_money
    @money ||= salaries.where(payed_at: nil, state: 'approved').sum(:money)
  end
  
  def delete!
    self.visible = false;
    self.save!
  end
  
end
