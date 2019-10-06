RSpec.shared_context 'index request' do |model_plural_name|
  let(:request_response) do
    request_params = respond_to?(:params) ? params : nil
    get url, params: request_params, headers: {'X-Api-Key': user.api_key}
    response
  end

  let(:response_records) { JSON.parse(request_response.body)[model_plural_name.to_s] }

  shared_examples 'expected records returned' do
    let(:expected_records_attributes) do
      expected_records.map { |record| extract_attributes(record, attributes) }
    end
    let(:response_records_attributes) do
      response_records.map { |record| extract_attributes(record, attributes) }
    end

    it 'has expected response' do
      expected = expected_records_attributes.map { |record| nested_hash_matcher(record) }
      expect(response_records_attributes).to contain_exactly(*expected)
    end
  end
end

RSpec.shared_context 'show request' do
  let(:request_response) do
    request_params = respond_to?(:params) ? params : nil
    record_id = extract_attributes(record, [:id])['id'] # gets id if it's an object or a hash
    get "#{url}/#{record_id}", params: request_params, headers: {'X-Api-Key': user.api_key}
    response
  end

  let(:expected_record) { record }
end


RSpec.shared_context 'create request' do |model_name|
  model_class = model_name.to_s.camelize.constantize
  let(:request_response) do
    request_params = respond_to?(:params) ? params : nil
    post "#{url}", params: request_params, headers: {'X-Api-Key': user.api_key}
    response
  end

  let(:response_record) { JSON.parse(request_response.body)[model_name.to_s] }
  let(:created_record) { model_class.find(response_record["id"]) }
  let(:expected_record) { created_record }

  shared_examples 'record is created' do
    let(:expected_record_attributes) do
      extract_attributes(params, attributes)
    end

    let(:created_record_attributes) { extract_attributes(created_record, attributes) }

    it 'has expected attributes' do
      expected = nested_hash_matcher(expected_record_attributes)
      expect(created_record_attributes).to match(expected)
    end
  end
end

RSpec.shared_examples 'expected record returned' do |model_name|
  let(:response_record) { JSON.parse(request_response.body)[model_name.to_s] }
  let(:expected_record_attributes) { extract_attributes(expected_record, attributes) }
  let(:response_record_attributes) { extract_attributes(response_record, attributes) }

  it 'has expected response' do
    expected = nested_hash_matcher(expected_record_attributes)
    expect(response_record_attributes).to match(expected)
  end
end

RSpec.shared_context 'destroy request' do
  let(:request_response) do
    request_params = respond_to?(:params) ? params : nil
    record_id = extract_attributes(record, [:id])['id'] # gets id if it's an object or a hash
    delete "#{url}/#{record_id}", params: request_params, headers: {'X-Api-Key': user.api_key}
    response
  end

  shared_examples 'record is destroyed' do
    it "destroys record" do
      request_response
      destroyed_record = record.class.find_by(id: record.id)
      expect(destroyed_record).to be_blank
    end
  end
end