class VideoCutterWorker
  include Sidekiq::Worker

  def perform(video_upload_id)
    video_upload = VideoUpload.find_by(id: video_upload_id)
    VideoUploadCutter.new(video_upload).call if video_upload.present?
  end
end