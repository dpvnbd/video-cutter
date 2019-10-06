require 'rails_helper'

RSpec.describe VideoUploadCutter do
  subject(:result) do
    described_class.new(video_upload).call
    video_upload.reload
  end

  shared_examples "processing is successful" do
    it "processing status is done" do
      expect(result.processing_status).to eq("done")
    end

    it "output file is attached" do
      expect(result.output_file.attached?).to eq(true)
    end

    it "sets duration of output file" do
      expected_duration = video_upload.to_seconds - video_upload.from_seconds
      expect(result.duration).to be_within(1).of(expected_duration)
    end
  end

  shared_examples "processing has failed" do
    it "processing status is failed" do
      expect(result.processing_status).to eq("failed")
    end

    it "output file is not attached" do
      expect(result.output_file.attached?).to eq(false)
    end
  end

  let(:video_upload) { create :video_upload, input_file: file }

  %i[mp4 webm].each do |extension|
    context "when valid #{extension}" do
      let(:file) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'files', "file.#{extension}")) }

      it_behaves_like "processing is successful"
    end
  end

  context "when valid upload has failed status" do
    let(:video_upload) { create :video_upload, :failed }

    it_behaves_like "processing is successful"
  end

  context "when corrupt input" do
    let(:file) { fixture_file_upload(Rails.root.join('spec', 'support', 'files', "file_corrupt.mp4")) }

    it_behaves_like "processing has failed"
  end
end