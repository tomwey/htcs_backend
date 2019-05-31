class Bank < ActiveRecord::Base
  validates :icon, :name, presence: true
  mount_uploader :icon, AvatarUploader
end
