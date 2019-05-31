class AuthProfile < ActiveRecord::Base
  def user
    @user ||= User.find_by(uid: self.user_id)
  end
end
