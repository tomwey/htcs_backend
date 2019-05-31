class LoanCondition < ActiveRecord::Base
  validates :name, presence: true
  mount_uploader :icon, AvatarUploader
end
