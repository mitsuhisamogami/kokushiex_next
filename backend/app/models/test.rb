class Test < ApplicationRecord
  validates :year, presence: true, uniqueness: true
  
  has_many :test_sessions, dependent: :destroy
  
  # Associations with models to be implemented later
  # has_many :questions, through: :test_sessions
  # has_many :examinations, dependent: :destroy
  # has_one :pass_mark, dependent: :destroy
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_year, ->(year) { where(year: year) }
  
  # TODO(human): Implement find_or_create_by_year class method
end