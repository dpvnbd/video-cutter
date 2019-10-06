FactoryBot.define do
  factory :video_upload do
    from_seconds { Faker::Number.between(0, 15) }
    to_seconds { Faker::Number.between(16, 30) }
    message { "Message" }
    input_file { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'files', 'file.mp4'), 'video/mp4') }

    trait :done do
      processing_status { :done }
      output_file { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'files', 'file.mp4'), 'video/mp4') }
    end

    trait :failed do
      processing_status { :failed }
    end
  end
end
