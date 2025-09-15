require 'rails_helper'

RSpec.describe User, type: :model do
  before(:each) do
    User.destroy_all
  end

  describe 'バリデーション' do
    it '有効な属性を持つ場合は有効である' do
      user = User.new(
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
        is_guest: false
      )
      expect(user).to be_valid
    end

    it '通常ユーザーでpassword_digestがない場合は無効である' do
      user = User.new(
        email: 'test@example.com',
        name: 'Test User',
        is_guest: false
      )
      expect(user).not_to be_valid
      expect(user.errors[:password_digest]).to include("can't be blank")
    end

    it 'ゲストユーザーの場合emailがなくても有効である' do
      user = User.new(
        password: 'password123',
        name: 'Test User',
        is_guest: true
      )
      expect(user).to be_valid
    end

    it 'emailの一意性を検証する' do
      User.create!(
        email: 'test@example.com',
        password: 'password123',
        name: 'First User',
        is_guest: false
      )

      duplicate_user = User.new(
        email: 'test@example.com',
        password: 'password456',
        name: 'Second User',
        is_guest: false
      )

      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:email]).to include('has already been taken')
    end

    it 'emailがnilの複数ユーザーを許可する' do
      user1 = User.create!(
        password: 'password123',
        name: 'User 1',
        is_guest: true
      )

      user2 = User.new(
        password: 'password456',
        name: 'User 2',
        is_guest: true
      )

      expect(user2).to be_valid
    end
  end

  describe '.create_guest_user' do
    it 'is_guestがtrueのゲストユーザーを作成する' do
      guest_user = User.create_guest_user

      expect(guest_user).to be_persisted
      expect(guest_user.is_guest).to be true
    end

    it 'emailなしのゲストユーザーを作成する' do
      guest_user = User.create_guest_user

      expect(guest_user.email).to be_nil
    end

    it 'nameなしのゲストユーザーを作成する' do
      guest_user = User.create_guest_user

      expect(guest_user.name).to be_nil
    end

    it 'ゲストユーザーに対してランダムなencrypted_passwordを生成する' do
      guest_user1 = User.create_guest_user
      guest_user2 = User.create_guest_user

      expect(guest_user1.password_digest).not_to eq(guest_user2.password_digest)
    end

    it '有効なゲストユーザーを作成する' do
      guest_user = User.create_guest_user

      expect(guest_user).to be_valid
    end

    it '24時間後の有効期限を設定する' do
      freeze_time = Time.current
      allow(Time).to receive(:current).and_return(freeze_time)

      guest_user = User.create_guest_user

      expected_expiry = freeze_time + 24.hours
      expect(guest_user.guest_expires_at).to be_within(1.second).of(expected_expiry)
    end

    it 'ゲストユーザー数が200人に達した場合エラーを発生させる' do
      # 200人のゲストユーザーを作成
      allow(User).to receive(:active_guest_count).and_return(200)

      expect {
        User.create_guest_user
      }.to raise_error(StandardError, "ゲストユーザー数が上限（200人）に達しています")
    end
  end

  describe 'ゲストユーザー管理メソッド' do
    let!(:active_guest) { User.create_guest_user }
    let!(:expired_guest) do
      guest = User.create_guest_user
      guest.update!(guest_expires_at: 1.hour.ago)
      guest
    end
    let!(:regular_user) { User.create!(email: 'regular@example.com', password: 'password123', is_guest: false) }

    describe '.active_guest_count' do
      it 'アクティブなゲストユーザー数を返す' do
        expect(User.active_guest_count).to eq(1)
      end
    end

    describe '.cleanup_expired_guests' do
      it '期限切れゲストユーザーのみを削除する' do
        expect {
          User.cleanup_expired_guests
        }.to change { User.count }.by(-1)

        expect(User.exists?(active_guest.id)).to be true
        expect(User.exists?(expired_guest.id)).to be false
        expect(User.exists?(regular_user.id)).to be true
      end

      it '削除されたゲストユーザー数を返す' do
        count = User.cleanup_expired_guests
        expect(count).to eq(1)
      end
    end

    describe '#guest_expired?' do
      it 'ゲストユーザーで期限切れの場合trueを返す' do
        expect(expired_guest.guest_expired?).to be true
      end

      it 'ゲストユーザーでまだ有効な場合falseを返す' do
        expect(active_guest.guest_expired?).to be false
      end

      it '通常ユーザーの場合falseを返す' do
        expect(regular_user.guest_expired?).to be false
      end
    end

    describe '#guest_remaining_seconds' do
      it 'ゲストユーザーの残り時間を秒で返す' do
        # 23時間後に期限切れのゲストユーザーを作成
        guest = User.create_guest_user
        guest.update!(guest_expires_at: 23.hours.from_now)

        remaining = guest.guest_remaining_seconds
        expect(remaining).to be_within(60).of(23.hours.to_i)
      end

      it '期限切れの場合0を返す' do
        expect(expired_guest.guest_remaining_seconds).to eq(0)
      end

      it '通常ユーザーの場合nilを返す' do
        expect(regular_user.guest_remaining_seconds).to be_nil
      end
    end
  end
end
