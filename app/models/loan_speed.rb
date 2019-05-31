class LoanSpeed < ActiveRecord::Base
  validates :name, :score, presence: true
end
