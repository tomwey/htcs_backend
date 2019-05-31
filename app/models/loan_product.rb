class LoanProduct < ActiveRecord::Base
  validates :name, :logo, :speed, :loan_rate, :length_type, :body_url, :body, presence: true
  validates :min_money, :max_money, :min_length, :max_length, numericality: { only_integer: true }, presence: true
  validates_numericality_of :pass_rate, :loan_rate
  
  mount_uploader :logo, AvatarUploader
  
  default_scope -> { where(deleted_at: nil) }
  
  LENGTH_TYPEs = [['按天计算', 1], ['按月计算', 2]]
  
  validate :min_value_gt_0
  def min_value_gt_0
    if min_money <= 0
      errors.add(:min_money, '必须大于0')
      return false
    end
    
    if min_length <= 0
      errors.add(:min_length, '必须大于0')
      return false
    end
  end
  
  validate :max_value_gt_min_value
  def max_value_gt_min_value
    if min_money > max_money
      errors.add(:max_money, '不能小于最小借款额度')
      return false
    end
    
    if min_length > max_length
      errors.add(:max_length, '不能小于最小借款期限')
      return false
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
    if self.opened_at.blank?
      self.opened_at = Time.zone.now
    end
  end
  
  before_save :remove_blank_value_for_array
  def remove_blank_value_for_array
    self.tags = self.tags.compact.reject(&:blank?)
    self.conditions = self.conditions.compact.reject(&:blank?)
  end
  
  def format_logo_url
    if self.logo.blank?
      ''
    else
      self.logo.url(:big)
    end
  end
  
  def loan_duration
    suffix = ''
    if self.length_type == 1 
      suffix = '日'
    elsif self.length_type == 2
      suffix = '月'
    end
    self.min_length < self.max_length ? "#{self.min_length}~#{self.max_length}#{suffix}" : "#{self.min_length}#{suffix}"
  end
  
  def loan_money
    real_loan_money.gsub('.0', '')
  end
  
  def real_loan_money
    if self.min_money < self.max_money
      if self.min_money >= 10000
        "#{'%.1f' % (self.min_money / 10000)}万~#{'%.1f' % (self.max_money / 10000)}万"
      else
        if self.max_money < 10000
          "#{self.min_money}~#{self.max_money}元"
        else
          "#{self.min_money}~#{'%.1f' % (self.max_money / 10000)}万"
        end
      end
      # "#{self.min_money}~#{self.max_money}元"
    else
      if self.min_money >= 10000
        "#{'%.1f' % (self.min_money / 10000)}万"
      else
        "#{self.min_money}元"
      end
    end
    # self.min_money < self.max_money ? "#{self.min_money}~#{self.max_money}元" : "#{self.min_money}元"
  end
  
  def format_loan_rate
    if self.length_type == 1
      "日利率: #{self.loan_rate}%"
    elsif self.length_type == 2
      "月利率: #{self.loan_rate}%"
    else
      ''
    end
  end
  
  def format_pass_rate
    if pass_rate.blank?
      ''
    else
      "#{pass_rate}%"
    end
  end
  
  def loan_speed
    LoanSpeed.find_by(score: speed).try(:name)
  end
  
  def tag_names
    Tag.where(id: tags).pluck(:name)
  end
  
  def condition_data
    LoanCondition.where(id: self.conditions).order('sort asc')
  end
  
  def condition_names
    LoanCondition.where(id: self.conditions).order('sort asc').pluck(:name)
  end
  
  def delete!
    self.deleted_at = Time.zone.now
    self.save!
  end
  
  def open!
    self.opened = true
    self.save!
  end
  
  def close!
    self.opened = false
    self.save!
  end
  
end

# t.integer :uniq_id
# t.string :name, null: false, default: ''
# t.string :logo, null: false
# t.integer :min_money, null: false
# t.integer :max_money, null: false
# t.integer :min_length, null: false
# t.integer :max_length, null: false
# t.integer :length_type, null: false
# t.string :intro
# t.integer :speed
# t.integer :tags, array: true, default: []
# t.string :pass_rate
# t.string :loan_rate
# t.integer :loan_rate_type
# t.string :body_url
# t.text :body
# t.integer :view_count, default: 0
# t.integer :order_count, default: 0
# t.datetime :opened_at
# t.datetime :deleted_at
# t.integer :sort, default: 0
