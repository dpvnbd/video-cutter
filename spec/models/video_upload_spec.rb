require 'rails_helper'

RSpec.describe VideoUpload, type: :model do
  describe "columns" do
    it { is_expected.to have_db_column(:from_seconds).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:to_seconds).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:processing_status).of_type(:integer).with_options(null: false, default: :scheduled) }
    it { is_expected.to define_enum_for(:processing_status).with_values(%i[scheduled processing done failed]) }
    it { is_expected.to have_db_column(:message).of_type(:string).with_options(null: true) }
    it { is_expected.to have_db_index(:processing_status) }
  end

  describe "validations" do
    subject(:video_upload) { create :video_upload }

    it { is_expected.to validate_presence_of(:from_seconds) }
    it { is_expected.to validate_presence_of(:to_seconds) }
    it { is_expected.to validate_numericality_of(:from_seconds).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:to_seconds).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_length_of(:message).is_at_most(300) }

    describe "to_seconds", focus: true do
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
  end
end
