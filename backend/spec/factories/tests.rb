FactoryBot.define do
  factory :test do
    sequence(:year) { |n| "第#{58 - n + 1}回" }
  end
end