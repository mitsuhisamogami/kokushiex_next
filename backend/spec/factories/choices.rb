FactoryBot.define do
  factory :choice do
    question
    sequence(:content) { |n| "選択肢#{n}" }
    sequence(:option_number) { |n| ((n - 1) % 5) + 1 }
    is_correct { false }

    trait :correct do
      is_correct { true }
    end

    trait :incorrect do
      is_correct { false }
    end
  end
end
