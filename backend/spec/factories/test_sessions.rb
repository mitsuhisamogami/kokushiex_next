FactoryBot.define do
  factory :test_session do
    test
    name { "午前" }
    session_type { "morning" }

    trait :morning do
      name { "午前" }
      session_type { "morning" }
    end

    trait :afternoon do
      name { "午後" }
      session_type { "afternoon" }
    end
  end
end
