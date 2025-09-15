FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    name { 'Test User' }
    is_guest { false }

    trait :guest do
      email { nil }
      name { nil }
      is_guest { true }
    end

    trait :with_name do
      name { Faker::Name.name }
    end
  end
end
