class VideoUploadSerializer < ActiveModel::Serializer
  attributes :id, :input_file_url, :output_file_url, :from_seconds, :to_seconds, :processing_status, :duration
end
