class Question < ApplicationRecord
  belongs_to :test_session
  has_many :choices, dependent: :destroy
  has_one_attached :image

  validates :content, presence: true
  validates :question_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :question_number, uniqueness: { scope: :test_session_id }

  scope :ordered, -> { order(:question_number) }
  scope :with_choices, -> { includes(:choices) }
  scope :with_images, -> { includes(image_attachment: :blob) }

  def correct_choice
    choices.find_by(is_correct: true)
  end

  def multiple_choice?
    choices.where(is_correct: true).count > 1
  end

  def has_image?
    image.attached?
  end
end
