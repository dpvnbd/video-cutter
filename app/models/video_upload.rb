class VideoUpload < ApplicationRecord
  has_one_attached :input_file
  has_one_attached :output_file

  validates :from_seconds, :to_seconds, :processing_status, presence: true
  validates :from_seconds, :to_seconds, numericality: {greater_than_or_equal_to: 0}
  validates :to_seconds, numericality: {greater_than: -> (video_upload) { video_upload.from_seconds || 0 }}
  validates :message, length: {maximum: 300}

  ALLOWED_FILE_TYPES = %w(video/mp4 video/webm video/x-matroska).freeze
  validates :input_file, attached: true, content_type: ALLOWED_FILE_TYPES, size: {less_than: 100.megabytes}
  validates :output_file, content_type: ALLOWED_FILE_TYPES, size: {less_than: 100.megabytes}

  enum processing_status: %i[scheduled processing done failed]
end