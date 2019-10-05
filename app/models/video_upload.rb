class VideoUpload < ApplicationRecord
    validates :from_seconds, :to_seconds, :processing_status, presence: true
    validates :from_seconds, :to_seconds, numericality: { greater_than_or_equal_to: 0 }
    validates :to_seconds, numericality: { greater_than: -> (video_upload) { video_upload.from_seconds || 0 }}
    validates :message, length: { maximum: 300 }
    enum processing_status: %i[scheduled processing done failed]
end
