class LoanApply < ActiveRecord::Base
  validates :user_id, :name, :idcard, presence: true
end
