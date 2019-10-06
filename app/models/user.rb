class User < ApplicationRecord
  before_validation :generate_api_key, on: :create

  has_many :video_uploads, dependent: :destroy

  validates :api_key, presence: true, length: {minimum: 60, maximum: 100}

  private

  def generate_api_key
    self.api_key ||= SecureRandom.urlsafe_base64(70)
  end
end
