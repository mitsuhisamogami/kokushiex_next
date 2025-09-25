FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    name { 'Test User' }
    is_guest { false }
    role { :regular }

    trait :guest do
      email { nil }
      name { nil }
      is_guest { true }
      role { :guest }
    end

    trait :admin do
      role { :admin }
    end

    trait :with_name do
      name { Faker::Name.name }
    end
  end
end
