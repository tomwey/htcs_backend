class AppVersion < ActiveRecord::Base
  validates :version, :os, :change_log, presence: true
  validates_uniqueness_of :version, scope: :os
  mount_uploader :app_file, AppFileUploader
  
  def app_url
    if self.app_download_url.blank?
      self.app_file.try(:url) || ''
    else
      self.app_download_url
    end
  end
end
