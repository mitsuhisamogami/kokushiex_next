class User < ApplicationRecord
  validates :encrypted_password, presence: true
  validates :email, uniqueness: true, allow_nil: true
  validates :is_guest, inclusion: { in: [true, false] }

  def self.create_guest_user
    random_string = SecureRandom.hex(10)
    create!(
      email: nil,
      encrypted_password: random_string,
      name: nil,
      is_guest: true
    )
  end
end