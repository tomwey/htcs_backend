require 'roo'

class Salary < ActiveRecord::Base
  validates :project_id, :money, :pay_name, :pay_account, presence: true
  validates :money, numericality: { greater_than_or_equal_to: 0 }
  
  belongs_to :user
  belongs_to :project
  
  before_create :generate_oid
  
  scope :unpayed, -> { where(payed_at: nil) }
  scope :payed, -> { where.not(payed_at: nil) }
  default_scope -> { where(visible: true).order('id desc') }
  
  state_machine initial: :pending do # 待审核
    state :approved # 已审核
    state :rejected # 被驳回
    state :payed    # 已发放
    
    event :approve do
      transition [:pending, :rejected] => :approved
    end
  
    event :reject do
      transition :pending => :rejected
    end
  end 
  
  def self.open_spreadsheet(file)
    ext = File.extname(file.original_filename)
    case ext
    when ".csv" then Csv.new(file.path, nil, :ignore)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
  
  def self.load_excel_data(file)
    spreadsheet = open_spreadsheet(file)
    # # puts spreadsheet.row(2)
    # # return '不正确的工资核对表文件' if spreadsheet.blank?
    #
    header = ['name', 'phone', 'money', 'settle_times']
    arr = []
    (1..spreadsheet.last_row).map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      arr << row
      # puts "#{row['name']},#{row['phone']},#{row['money']}"
      
    end
    
    ImportSalaryJob.perform_later(arr)
    
    return ''
    
  end
  
  def self.calc_score(settle_times)
    return nil if settle_times.blank?
    arr = settle_times.split(',')
    score = 0
    arr.each do |time|
      temp = time.split('-')
      temp.each do |d|
        score += d.to_i
      end
    end
    score
  end
  
  def state_name
    name = case self.state
    when 'pending' then '待审核'
    when 'approved' then '已审核'
    when 'rejected' then '被驳回'
    when 'payed' then '已发放'
    else ''
    end
    name
  end
  
  def delete!
    self.visible = false;
    self.save!
  end
  
  def generate_oid
    begin
      self.uniq_id = Time.now.to_s(:number)[2,6] + (Time.now.to_i - Date.today.to_time.to_i).to_s + Time.now.nsec.to_s[0,6]
    end while self.class.exists?(:uniq_id => uniq_id)
  end
  
  def self.all_projects_for(user)
    proj_ids = Salary.where(user_id: user.id).pluck(:project_id)
    Project.where(opened: true).where.not(id: proj_ids).order('id desc').limit(5)
  end
  
  def confirm_pay!
    if self.payed_at.present? or self.state == 'payed'
      return '工资已发放'
    end
    
    if self.state != 'approved'
      return '工资申请未审核通过'
    end
    
    code,msg = Alipay::Pay.pay(self.uniq_id, self.pay_account, self.pay_name, (money * 100))
    if code == 0
      self.payed_at = Time.zone.now
      self.state = 'payed'
      self.save!
      
      # 通知管理员
      # notify_backend_manager('')
      
      return ''
    else
      
      # 通知管理员
      # notify_backend_manager(msg)
      
      return msg
    end
  end # end method
  
end
