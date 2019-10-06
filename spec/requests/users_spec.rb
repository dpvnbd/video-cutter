require 'rails_helper'

RSpec.describe "users" do
  let(:url) { "/api/v1/users" }

  describe "#create" do
    response_keys = %w[id api_key]

    let(:request_response) do
      post url
      response
    end

    let(:response_record) do
      JSON.parse(request_response.body)['user']
    end

    let(:created_record) { User.find(response_record["id"]) }

    it "responds with created" do
      expect(request_response).to have_http_status(:created)
    end

    it "responds with correct attributes" do
      created_record_attributes = created_record.attributes.slice(*response_keys)
      response_record_attributes = response_record.slice(*response_keys)
      expect(response_record_attributes).to include(created_record_attributes)
    end
  end
end