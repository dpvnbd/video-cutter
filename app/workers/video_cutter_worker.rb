class VideoCutterWorker
  include Sidekiq::Worker

  def perform(video_upload_id)
    video_upload = VideoUpload.find_by(id: video_upload_id)
    if video_upload.blank?
      logger.warn "Can't find video upload #{video_upload_id}"
    else
      VideoUploadCutter.new(video_upload).call
      logger.info "Cutting is finished for #{video_upload_id}"
    end
  end
end