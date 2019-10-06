require "rails_helper"

RSpec.describe VideoCutterWorker do
  subject(:run_worker) { described_class.perform_async(video_upload_id) }
  let(:video_upload_id) { video_upload.id }
  let(:video_upload) { create :video_upload }
  context "when video upload exists" do
    it "runs cutter service" do
      Sidekiq::Testing.inline! do
        expect_any_instance_of(VideoUploadCutter).to receive(:call)
        run_worker
      end
    end

    it "adds job to queue" do
      expect {
        run_worker
      }.to change(described_class.jobs, :size).by(1)
    end
  end

  context "when video upload doesn't exist" do
    let(:video_upload_id) { "missing" }

    it "doesn't run cutter service" do
      Sidekiq::Testing.inline! do
        expect_any_instance_of(VideoUploadCutter).not_to receive(:call)
        run_worker
      end
    end
  end
end