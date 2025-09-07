FactoryBot.define do
  factory :question do
    test_session
    content { "次の中で正しいものはどれか。" }
    sequence(:question_number) { |n| n }
    category { "解剖学" }
    explanation { "解説文" }

    trait :with_image do
      after(:build) do |question|
        question.image.attach(
          io: StringIO.new('dummy'),
          filename: 'test.png',
          content_type: 'image/png'
        )
      end
    end

    trait :with_choices do
      after(:create) do |question|
        create_list(:choice, 5, question: question)
      end
    end

    trait :with_correct_choice do
      after(:create) do |question|
        create(:choice, question: question, option_number: 1, is_correct: true)
        create_list(:choice, 4, question: question, is_correct: false) do |choice, i|
          choice.option_number = i + 2
        end
      end
    end
  end
end
