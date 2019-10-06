class VideoUpload < ApplicationRecord
  has_one_attached :input_file
  has_one_attached :output_file
  belongs_to :user

  enum processing_status: %i[scheduled processing done failed], _prefix: :processing

  validates :from_seconds, :to_seconds, :processing_status, presence: true
  validates :from_seconds, :to_seconds, numericality: {greater_than_or_equal_to: 0}
  validates :duration, numericality: {greater_than_or_equal_to: 0, allow_nil: true}
  validates :to_seconds, numericality: {greater_than: -> (video_upload) { video_upload.from_seconds || 0 }}
  validates :message, length: {maximum: 300}

  ALLOWED_FILE_TYPES = %w[video/mp4 video/webm].freeze
  validates :input_file, attached: true, content_type: ALLOWED_FILE_TYPES, size: {less_than: 100.megabytes}
  validates :output_file, content_type: ALLOWED_FILE_TYPES, size: {less_than: 100.megabytes}

  %i[input_file output_file].each do |attachment_name|
    define_method "#{attachment_name}_url" do
      attachment = send(attachment_name)
      Rails.application.routes.url_helpers.rails_blob_url(attachment) if attachment.attached?
    end

    define_method "#{attachment_name}_path" do
      attachment = send(attachment_name)
      ActiveStorage::Blob.service.path_for(attachment.key) if attachment.attached?
    end
  end

  def restart_allowed?
    self.processing_failed?
  end
end
