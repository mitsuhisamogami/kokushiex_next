class User < ApplicationRecord
  # 定数定義
  GUEST_USER_LIMIT = 200
  GUEST_EXPIRATION_HOURS = 24

  # ロール定義
  enum role: {
    guest: 0,
    regular: 1,
    admin: 2
  }

  has_secure_password validations: false

  validates :email, uniqueness: true, allow_nil: true
  validates :is_guest, inclusion: { in: [ true, false ] }

  # 通常ユーザーの場合のバリデーション
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, unless: :is_guest
  validates :password, length: { minimum: 8 }, allow_nil: true, unless: :is_guest
  validates :password, confirmation: true, if: :password_digest_changed?, unless: :is_guest
  validates :password_digest, presence: true, unless: :is_guest

  # スコープ定義
  scope :guests, -> { where(is_guest: true) }
  scope :regular_users, -> { where(is_guest: false) }
  scope :expired_guests, -> { guests.where("guest_expires_at < ?", Time.current) }
  scope :active_guests, -> { guests.where("guest_expires_at >= ?", Time.current) }

  # ゲストユーザー作成メソッド（拡張版）
  def self.create_guest_user
    # ゲストユーザー数の上限チェック
    if active_guest_count >= GUEST_USER_LIMIT
      raise StandardError, "ゲストユーザー数が上限（#{GUEST_USER_LIMIT}人）に達しています"
    end

    random_string = SecureRandom.hex(10)
    user = new(
      email: nil,
      name: nil,
      is_guest: true,
      role: :guest,  # 新しいrole属性を設定
      guest_expires_at: GUEST_EXPIRATION_HOURS.hours.from_now
    )
    user.password_digest = BCrypt::Password.create(random_string)
    user.save!
    user
  end

  # アクティブなゲストユーザー数を取得
  def self.active_guest_count
    active_guests.count
  end

  # 期限切れゲストユーザーを削除
  def self.cleanup_expired_guests
    expired_count = expired_guests.count
    expired_guests.destroy_all
    Rails.logger.info "Cleaned up #{expired_count} expired guest users"
    expired_count
  end

  # ゲストユーザーかどうかチェック
  def guest_expired?
    is_guest && guest_expires_at && guest_expires_at < Time.current
  end

  # ゲストユーザーの残り時間（秒）
  def guest_remaining_seconds
    return nil unless is_guest && guest_expires_at
    seconds = (guest_expires_at - Time.current).to_i
    seconds.positive? ? seconds : 0
  end

  # ゲストユーザーの残り時間（フォーマット済み）
  def guest_remaining_time
    seconds = guest_remaining_seconds
    return nil unless seconds

    hours = seconds / 3600
    minutes = (seconds % 3600) / 60
    "#{hours}時間#{minutes}分"
  end
end
