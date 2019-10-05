require 'rails_helper'

RSpec.fdescribe VideoUploadCutter do
    subject(:result) do
        described_class.new(video_upload).call
        video_upload.reload 
    end

    context "when valid video upload" do
        let(:video_upload) { create :video_upload }

        it "adds output file" do
            expect(video_upload.output_file.attached?).to eq(true) 
        end
    end
end