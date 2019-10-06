require 'rails_helper'

RSpec.describe User, type: :model do
  describe "columns" do
    it { is_expected.to have_db_column(:api_key).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_index(:api_key) }
  end

  describe "validations" do
    # it { is_expected.to validate_presence_of(:api_key) }
    it { is_expected.to validate_length_of(:api_key).is_at_least(60).is_at_most(100) }
  end

  describe "assoociations" do
    it { is_expected.to have_many(:video_uploads).dependent(:destroy) }
  end

  describe "api_key" do
    context "when creating record without api_key" do
      subject(:user) { User.create }

      it "generates api_key" do
        expect(user.api_key).to be_present
      end

      it "generates api_key with minimum length" do
        expect(user.api_key.size).to be >= 60
      end
    end
  end
end
