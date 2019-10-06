FactoryBot.define do
  factory :user do
    trait :with_video_uploads do
      after(:create) do |user|
        create :video_upload, user: user
        create :video_upload, :done, user: user
      end
    end
  end
end
