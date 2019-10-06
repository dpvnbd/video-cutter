require 'rails_helper'

RSpec.describe "video_uploads" do
  let(:url) { "/api/v1/video_uploads" }
  let(:attributes) { %i[id input_file_url output_file_url from_seconds to_seconds processing_status] }

  let(:user) { create :user, :with_video_uploads }

  describe "#index" do
    include_context "index request", :video_uploads

    let!(:other_video_uploads) { create_list :video_upload, 2 }

    context "when authenticated" do
      let(:expected_records) { user.video_uploads }

      it_behaves_like "expected records returned"
    end

    context "when not authenticated" do
      it "responds with unauthorized" do
        get url
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "#show" do
    include_context "show request", :video_upload
    let!(:other_video_upload) { create :video_upload }
    let(:record) { create :video_upload, :done }

    context "when owner of the upload" do
      let(:user) { record.user }
      it_behaves_like "expected record returned", :video_upload
    end

    context "when not owner of the upload" do
      it "responds with not found" do
        expect(request_response).to have_http_status(:not_found)
      end
    end

    context "when video upload doesn't exist" do
      let(:record) { {id: 'missing'} }
      it "responds with not found" do
        expect(request_response).to have_http_status(:not_found)
      end
    end
  end

  describe "#destroy" do
    include_context "destroy request"
    let(:record) { create :video_upload, :done }

    context "when owner of the upload" do
      let(:user) { record.user }
      it_behaves_like "record is destroyed"
    end

    context "when not owner of the upload" do
      it "responds with not found" do
        expect(request_response).to have_http_status(:not_found)
      end
    end

    context "when video upload doesn't exist" do
      let(:record) { {id: 'missing'} }
      it "responds with not found" do
        expect(request_response).to have_http_status(:not_found)
      end
    end
  end

  describe "#create" do
    let(:attributes) { %i[from_seconds to_seconds] }
    include_context "create request", :video_upload

    let(:params) do
      {
        input_file: input_file,
        from_seconds: 2,
        to_seconds: 5
      }
    end
    let(:input_file) { fixture_file_upload(Rails.root.join('spec', 'support', 'files', "file.mp4")) }

    context "when valid params" do
      it_behaves_like "record is created"
      it_behaves_like "expected record returned", :video_upload

      it "attaches input file" do
        expect(created_record.input_file.attached?).to eq(true)
      end

      it "adds cutting job to queue" do
        expect { request_response }.to change(VideoCutterWorker.jobs, :size).by(1)
      end
    end

    context "when invalid params" do
      let(:params) do
        {
          from_seconds: -12,
        }
      end

      it "responds with unprocessable entity" do
        expect(request_response).to have_http_status(:unprocessable_entity)
      end

      it "doesn't add cutting job to queue" do
        expect { request_response }.not_to change(VideoCutterWorker.jobs, :size)
      end
    end
  end

  describe "#restart" do
    let(:request_response) do
      post "#{url}/#{record_id}/restart", headers: {'X-Api-Key': user.api_key}
      response
    end
    let(:record) { create :video_upload, :failed }
    let(:expected_record) { record }
    let(:record_id) { record.id }

    context "when owner of the upload" do
      let(:user) { record.user }
      it_behaves_like "expected record returned", :video_upload

      it "adds cutting job to queue" do
        expect { request_response }.to change(VideoCutterWorker.jobs, :size).by(1)
      end
    end

    context "when not owner of the upload" do
      it "responds with not found" do
        expect(request_response).to have_http_status(:not_found)
      end
    end

    context "when video upload doesn't exist" do
      let(:record_id) { 'missing' }
      it "responds with not found" do
        expect(request_response).to have_http_status(:not_found)
      end
    end

    context "when upload is not failed" do
      let(:record) { create :video_upload }

      let(:user) { record.user }
      it "returns bad request" do
        expect(request_response).to have_http_status(:bad_request)
      end

      it "doesn't add cutting job to queue" do
        expect { request_response }.not_to change(VideoCutterWorker.jobs, :size)
      end
    end
  end
end
