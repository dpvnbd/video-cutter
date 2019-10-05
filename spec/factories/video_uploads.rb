FactoryBot.define do
  factory :video_upload do
    from_seconds { Faker::Number.between(0, 10) }
    to_seconds { Faker::Number.between(11, 30) }
    message { "Message" }
    input_file { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'files', 'file.mp4'), 'video/mp4') }

    trait :with_output_file do
      output_file { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'files', 'file.mp4'), 'video/mp4') }
    end
  end
end
