require 'rails_helper'

RSpec.describe VideoUpload, type: :model do
  describe "columns" do
    it { is_expected.to have_db_column(:from_seconds).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:to_seconds).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:duration).of_type(:float) }
    it { is_expected.to have_db_column(:processing_status).of_type(:integer).with_options(null: false, default: :scheduled) }
    it { is_expected.to define_enum_for(:processing_status).with_values(%i[scheduled processing done failed]).with_prefix(:processing) }
    it { is_expected.to have_db_column(:message).of_type(:string).with_options(null: true) }
    it { is_expected.to have_db_index(:processing_status) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    subject(:video_upload) { create :video_upload }

    it { is_expected.to validate_presence_of(:from_seconds) }
    it { is_expected.to validate_presence_of(:to_seconds) }
    it { is_expected.to validate_numericality_of(:from_seconds).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:to_seconds).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:duration).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_length_of(:message).is_at_most(300) }

    it "input_file attached" do
      video_upload = build :video_upload, input_file: nil
      expect(video_upload).to be_invalid
    end

    describe "to_seconds" do
      subject { build :video_upload, from_seconds: from_seconds, to_seconds: to_seconds }
      let(:from_seconds) { 10 }

      context "when greater than from_seconds" do
        let(:to_seconds) { from_seconds + 1 }
        it { is_expected.to be_valid }
      end

      context "when equal to from_seconds" do
        let(:to_seconds) { from_seconds }
        it { is_expected.to be_invalid }
      end

      context "when less than from_seconds" do
        let(:to_seconds) { from_seconds - 1 }
        it { is_expected.to be_invalid }
      end

      context "when from_seconds is nil" do
        let(:from_seconds) { nil }
        let(:to_seconds) { 1 }
        it { is_expected.to be_invalid }
      end
    end

    describe "file formats" do
      valid_files = %w[file.mp4 file.webm file_corrupt.mp4]
      invalid_files = %w[file file.png]

      valid_files.each do |filename|
        context "when #{filename}" do
          let(:file) { fixture_file_upload(Rails.root.join('spec', 'support', 'files', filename)) }

          it { is_expected.to allow_value(file).for(:input_file) }
          it { is_expected.to allow_value(file).for(:output_file) }
        end
      end

      invalid_files.each do |filename|
        context "when #{filename}" do
          let(:file) { fixture_file_upload(Rails.root.join('spec', 'support', 'files', filename)) }

          it { is_expected.not_to allow_value(file).for(:input_file) }
          it { is_expected.not_to allow_value(file).for(:output_file) }
        end
      end
    end

    describe "file size" do
      context "when 30mb" do
        let(:file) { fixture_file_upload(Rails.root.join('spec', 'support', 'files', "file_30mb.mp4")) }
        it { is_expected.to allow_value(file).for(:input_file) }
      end

      # TODO: test upper limit (and add a large file to the repository?)
    end
  end

  describe "file locations" do
    context "when files attached" do
      let(:video_upload) { create :video_upload, :done }

      %i[input_file output_file].each do |attribute|
        url_attribute = "#{attribute}_url"
        path_attribute = "#{attribute}_path"

        it "has #{url_attribute}" do
          expect(video_upload.send(url_attribute)).to be_present
        end

        it "has #{path_attribute}" do
          expect(video_upload.send(path_attribute)).to be_present
        end
      end
    end

    context "when output file is not attached" do
      let(:video_upload) { create :video_upload }
      it "doesn't have output_file_url" do
        expect(video_upload.output_file_url).to be_nil
      end

      it "doesn't have output_file_path" do
        expect(video_upload.output_file_path).to be_nil
      end
    end
  end

  describe "restart_allowed?" do
    allowed_statuses = [:failed]
    forbidden_statuses = [:scheduled, :processing, :done]

    allowed_statuses.each do |status|
      context "when #{status}" do
        let(:video_upload) { create :video_upload, processing_status: status }

        it "allows restart" do
          expect(video_upload.restart_allowed?).to eq(true)
        end
      end
    end

    forbidden_statuses.each do |status|
      context "when #{status}" do
        let(:video_upload) { create :video_upload, processing_status: status }

        it "doesn't allow restart" do
          expect(video_upload.restart_allowed?).to eq(false)
        end
      end
    end
  end
end
