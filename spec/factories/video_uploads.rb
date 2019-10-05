FactoryBot.define do
  factory :video_upload do
    from_seconds { Faker::Number.between(0, 10) }
    to_seconds { Faker::Number.between(11, 30) }
    message { "Message" }
  end
end
