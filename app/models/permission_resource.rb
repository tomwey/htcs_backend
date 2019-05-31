class PermissionResource < ActiveRecord::Base
  validates :func_name, :func_class, presence: true
  
  has_many :permissions, dependent: :destroy, foreign_key: :resource_id
  accepts_nested_attributes_for :permissions, allow_destroy: true, reject_if: proc { |a| a[:action].blank? or a[:action_name].blank? }
end
