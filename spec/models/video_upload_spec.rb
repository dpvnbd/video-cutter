require 'rails_helper'

RSpec.describe VideoUpload, type: :model do
  describe "columns" do
    it { is_expected.to have_db_column(:from_seconds).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:to_seconds).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:processing_status).of_type(:integer).with_options(null: false, index: true) }
    it { is_expected.to define_enum_for(:processing_status).with_values(%i[scheduled processing done failed]) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:from_seconds) }
    it { is_expected.to validate_presence_of(:to_seconds) }
    it { is_expected.to validate_numericality_of(:from_seconds) }
    it { is_expected.to validate_numericality_of(:to_seconds).is_greater_than(:from_seconds) }
  end
end
