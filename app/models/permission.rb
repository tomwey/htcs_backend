class Permission < ActiveRecord::Base
  validates :action, :action_name, presence: true
  belongs_to :permission_resource, foreign_key: 'resource_id'
  has_and_belongs_to_many :admin_users
  
  delegate :func_name, :func_class, allow_nil: true, to: :permission_resource
end
