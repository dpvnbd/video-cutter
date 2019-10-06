require 'streamio-ffmpeg'

class VideoUploadCutter
  attr_reader :video_upload, :movie

  def initialize(video_upload)
    @video_upload = video_upload
    @movie = FFMPEG::Movie.new(video_upload.input_file_path)
  end

  def call
    set_status(:processing)
    begin
      Rails.logger.info("#{video_upload.id} cutting started")
      output = movie.transcode(temp_output_path, command_arguments)
      output_filename = "processed_#{input_file_name}"
      @video_upload.output_file.attach(io: File.open(temp_output_path), filename: output_filename)
      @video_upload.update(duration: output.duration)
    rescue FFMPEG::Error => e
      Rails.logger.error("#{video_upload.id} cutting has failed: #{e.message}")
      set_status(:failed)
    else
      Rails.logger.info("#{video_upload.id} cutting is done")
      set_status(:done)
    ensure
      FileUtils.rm_f(temp_output_path)
      Rails.logger.info("#{video_upload.id} temp output deleted")
    end
  end

  private

  def command_arguments
    # ffmpeg -ss 78 -i input.mp4 -to 10 -c copy output.mp4
    [
        "-ss", video_upload.from_seconds.to_s, # seek to timestamp
        '-to', video_upload.to_seconds.to_s, # timestamp to cut to
        '-c', 'copy' #  trim via stream copy (very fast)
    ]
  end

  def input_file_name
    video_upload.input_file.blob.filename
  end

  def temp_output_path
    output_extension = input_file_name.extension
    Rails.root.join('tmp', "cutter-out-#{video_upload.id}.#{output_extension}").to_s
  end

  def set_status(processing_status)
    video_upload.update(processing_status: processing_status)
  end
end