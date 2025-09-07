require 'rails_helper'

RSpec.describe JwtService do
  let(:user_id) { 1 }
  let(:payload) { { user_id: user_id } }
  let(:secret_key) { Rails.application.credentials.secret_key_base || 'test_secret_key' }

  describe '.encode' do
    it 'トークンを正常にエンコードできること' do
      token = JwtService.encode(payload)
      expect(token).to be_a(String)
      expect(token.split('.').length).to eq(3) # JWT形式の確認
    end

    it 'ペイロードが空でもエンコードできること' do
      token = JwtService.encode({})
      expect(token).to be_a(String)
    end

    it 'expiration時刻が設定されること' do
      # TODO(human): JWTServiceのencodeメソッドでexpiration時刻を設定する実装を追加
      token = JwtService.encode(payload)
      decoded = JWT.decode(token, secret_key, true, { algorithm: 'HS256' })[0]

      expect(decoded['exp']).to be_present
      expect(decoded['exp']).to be > Time.current.to_i
    end
  end

  describe '.decode' do
    let(:valid_token) { JwtService.encode(payload) }

    it '有効なトークンを正常にデコードできること' do
      decoded_payload = JwtService.decode(valid_token)
      expect(decoded_payload['user_id']).to eq(user_id)
    end

    it '無効なトークンでnilを返すこと' do
      invalid_token = 'invalid.token.string'
      expect(JwtService.decode(invalid_token)).to be_nil
    end

    it '期限切れトークンでnilを返すこと' do
      # 過去の時刻でトークンを作成
      expired_payload = payload.merge(exp: 1.hour.ago.to_i)
      expired_token = JWT.encode(expired_payload, secret_key, 'HS256')

      expect(JwtService.decode(expired_token)).to be_nil
    end

    it '空文字列でnilを返すこと' do
      expect(JwtService.decode('')).to be_nil
    end

    it 'nilでnilを返すこと' do
      expect(JwtService.decode(nil)).to be_nil
    end
  end
end
