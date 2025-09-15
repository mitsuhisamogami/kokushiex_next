require 'rails_helper'

RSpec.describe CleanupExpiredGuestUsersJob, type: :job do
  before(:each) do
    User.destroy_all
  end

  describe '#perform' do
    let!(:active_guest) { User.create_guest_user }
    let!(:expired_guest1) do
      guest = User.create_guest_user
      guest.update!(guest_expires_at: 2.hours.ago)
      guest
    end
    let!(:expired_guest2) do
      guest = User.create_guest_user
      guest.update!(guest_expires_at: 1.hour.ago)
      guest
    end
    let!(:regular_user) { User.create!(email: 'regular@example.com', password: 'password123', is_guest: false) }

    it '期限切れゲストユーザーのみを削除する' do
      expect {
        CleanupExpiredGuestUsersJob.new.perform
      }.to change { User.count }.by(-2)

      # アクティブなゲストユーザーと通常ユーザーは残る
      expect(User.exists?(active_guest.id)).to be true
      expect(User.exists?(regular_user.id)).to be true

      # 期限切れゲストユーザーは削除される
      expect(User.exists?(expired_guest1.id)).to be false
      expect(User.exists?(expired_guest2.id)).to be false
    end

    it 'ログに適切な情報を出力する' do
      expect(Rails.logger).to receive(:info).with("Starting cleanup of expired guest users").ordered
      expect(Rails.logger).to receive(:info).with("Cleaned up 2 expired guest users").ordered
      expect(Rails.logger).to receive(:info).with("Cleanup completed. Removed 2 expired guest users").ordered
      expect(Rails.logger).to receive(:info).with("Current active guest users: 1/200").ordered

      CleanupExpiredGuestUsersJob.new.perform
    end

    context '期限切れユーザーがいない場合' do
      before do
        # 期限切れユーザーを削除
        expired_guest1.destroy!
        expired_guest2.destroy!
      end

      it '何も削除せずに0を報告する' do
        expect {
          CleanupExpiredGuestUsersJob.new.perform
        }.not_to change { User.count }
      end

      it 'ログに0件削除を出力する' do
        expect(Rails.logger).to receive(:info).with("Starting cleanup of expired guest users").ordered
        expect(Rails.logger).to receive(:info).with("Cleaned up 0 expired guest users").ordered
        expect(Rails.logger).to receive(:info).with("Cleanup completed. Removed 0 expired guest users").ordered
        expect(Rails.logger).to receive(:info).with("Current active guest users: 1/200").ordered

        CleanupExpiredGuestUsersJob.new.perform
      end
    end
  end
end
