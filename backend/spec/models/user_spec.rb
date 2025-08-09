require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    it '有効な属性を持つ場合は有効である' do
      user = User.new(
        email: 'test@example.com',
        encrypted_password: 'password123',
        name: 'Test User',
        is_guest: false
      )
      expect(user).to be_valid
    end

    it 'encrypted_passwordがない場合は無効である' do
      user = User.new(
        email: 'test@example.com',
        name: 'Test User',
        is_guest: false
      )
      expect(user).not_to be_valid
      expect(user.errors[:encrypted_password]).to include("can't be blank")
    end

    it 'emailがなくても有効である' do
      user = User.new(
        encrypted_password: 'password123',
        name: 'Test User',
        is_guest: false
      )
      expect(user).to be_valid
    end

    it 'emailの一意性を検証する' do
      User.create!(
        email: 'test@example.com',
        encrypted_password: 'password123',
        name: 'First User',
        is_guest: false
      )
      
      duplicate_user = User.new(
        email: 'test@example.com',
        encrypted_password: 'password456',
        name: 'Second User',
        is_guest: false
      )
      
      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:email]).to include('has already been taken')
    end

    it 'emailがnilの複数ユーザーを許可する' do
      user1 = User.create!(
        encrypted_password: 'password123',
        name: 'User 1',
        is_guest: true
      )
      
      user2 = User.new(
        encrypted_password: 'password456',
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
      
      expect(guest_user1.encrypted_password).not_to eq(guest_user2.encrypted_password)
    end

    it '有効なゲストユーザーを作成する' do
      guest_user = User.create_guest_user
      
      expect(guest_user).to be_valid
    end
  end
end