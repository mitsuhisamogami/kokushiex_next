class User < ApplicationRecord
  has_secure_password validations: false

  validates :email, uniqueness: true, allow_nil: true
  validates :is_guest, inclusion: { in: [ true, false ] }

  # 通常ユーザーの場合のバリデーション
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, unless: :is_guest
  validates :password, length: { minimum: 8 }, allow_nil: true, unless: :is_guest
  validates :password, confirmation: true, if: :password_digest_changed?, unless: :is_guest
  validates :password_digest, presence: true, unless: :is_guest

  def self.create_guest_user
    random_string = SecureRandom.hex(10)
    user = new(
      email: nil,
      name: nil,
      is_guest: true
    )
    user.password_digest = BCrypt::Password.create(random_string)
    user.save!
    user
  end
end
