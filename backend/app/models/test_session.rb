class TestSession < ApplicationRecord
  belongs_to :test

  validates :name, presence: true
  validates :session_type, presence: true
  validates :session_type, uniqueness: { scope: :test_id }

  has_many :questions, dependent: :destroy

  scope :morning, -> { where(session_type: "morning") }
  scope :afternoon, -> { where(session_type: "afternoon") }

  def morning?
    session_type == "morning"
  end

  def afternoon?
    session_type == "afternoon"
  end
end
