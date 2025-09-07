class Choice < ApplicationRecord
  belongs_to :question

  validates :content, presence: true
  validates :option_number, presence: true, numericality: { in: 1..5 }

  scope :ordered, -> { order(:option_number) }
  scope :correct, -> { where(is_correct: true) }
end
