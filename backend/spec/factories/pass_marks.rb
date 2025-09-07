FactoryBot.define do
  factory :pass_mark do
    association :test
    required_score { 168 }
    required_practical_score { 41 }
    total_score { 280 }
  end
end
