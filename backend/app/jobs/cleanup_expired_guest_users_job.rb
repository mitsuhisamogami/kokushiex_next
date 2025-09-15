class CleanupExpiredGuestUsersJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting cleanup of expired guest users"

    expired_count = User.cleanup_expired_guests

    Rails.logger.info "Cleanup completed. Removed #{expired_count} expired guest users"

    # 統計情報をログに出力
    active_guest_count = User.active_guest_count
    Rails.logger.info "Current active guest users: #{active_guest_count}/#{User::GUEST_USER_LIMIT}"
  end
end
