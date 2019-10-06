require 'swagger_helper'

RSpec.describe 'Video uploads' do
  let(:user) { create :user, :with_video_uploads }
  path '/video_uploads' do
    post 'Creates a video upload' do
      tags 'Video Uploads'
      consumes 'multipart/form-data'

      parameter name: :input_file, in: :formData, type: :file, required: true, description: "Input video, mp4 or webm, maximum 100MB"
      parameter name: :from_seconds, in: :formData, required: true, description: "Number of seconds from the start of video"
      parameter name: :to_seconds, in: :formData, required: true, description: "Number of seconds from the start of video, must be greater than from_seconds"

      response '201', 'upload created' do
        let(:input_file) { fixture_file_upload(Rails.root.join('spec', 'support', 'files', "file.mp4")) }
        let(:from_seconds) { 3 }
        let(:to_seconds) { 8 }

        run_test!
      end

      response '422', 'upload invalid' do
        let(:input_file) { fixture_file_upload(Rails.root.join('spec', 'support', 'files', "file.png")) }
        let(:from_seconds) { -3 }
        let(:to_seconds) { nil }

        run_test!
      end
    end

    get 'Lists uploads' do
      tags 'Video Uploads'

      response '200', 'list of records' do
        run_test!
      end
    end
  end

  path "/video_uploads/{id}" do
    delete "Deletes upload" do
      tags 'Video Uploads'
      parameter name: :id, in: :path, required: true, type: :string

      let(:deleted_record) { create :video_upload, user: user }
      let(:id) { deleted_record.id }

      response "204", "Video upload is deleted" do
        run_test!
      end

      response "404", "Video upload not found" do
        let(:id) { "f9f29e49-a49d-44b0-afa1-3d81c1b41039" }
        run_test!
      end
    end

    get "Shows upload" do
      tags 'Video Uploads'
      parameter name: :id, in: :path, required: true, type: :string

      let(:record) { create :video_upload, :done, user: user }
      let(:id) { record.id }

      response "200", "record" do
        run_test!
      end

      response "404", "Video upload not found" do
        let(:id) { "f9f29e49-a49d-44b0-afa1-3d81c1b41039" }
        run_test!
      end
    end
  end

  path "/video_uploads/{id}/restart" do
    post "Restarts processing" do
      tags 'Video Uploads'
      parameter name: :id, in: :path, required: true, type: :string

      let(:id) { record.id }

      response "200", "Video upload processing is restarted" do
        let(:record) { create :video_upload, :failed, user: user }

        run_test!
      end

      response "400", "Video upload not failedd" do
        let(:record) { create :video_upload, :done, user: user }
        run_test!
      end

      response "404", "Video upload not found" do
        let(:id) { "f9f29e49-a49d-44b0-afa1-3d81c1b41039" }
        run_test!
      end
    end
  end
end