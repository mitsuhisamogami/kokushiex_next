class PassMark < ApplicationRecord
  belongs_to :test

  validates :test_id, uniqueness: true
  validates :required_score, presence: true
  validates :required_practical_score, presence: true
  validates :total_score, presence: true
end
