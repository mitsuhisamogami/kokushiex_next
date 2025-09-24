require 'rails_helper'

RSpec.describe CsrfTokenService do
  describe '.generate' do
    let(:token) { CsrfTokenService.generate }

    it 'トークンを正常に生成できること' do
      expect(token).to be_a(String)
    end

    it '32文字のトークンが生成されること' do
      expect(token.length).to eq(32)
    end

    it 'URLセーフな文字のみが使用されること' do
      expect(token).to match(/\A[A-Za-z0-9_-]+\z/)
    end

    it '複数回呼び出しで異なるトークンが生成されること' do
      token1 = CsrfTokenService.generate
      token2 = CsrfTokenService.generate
      expect(token1).not_to eq(token2)
    end

    it '空でないトークンが生成されること' do
      expect(token).not_to be_empty
    end
  end

  describe '.verify' do
    let(:valid_token) { CsrfTokenService.generate }

    context '正常なトークンペアの場合' do
      it 'trueを返すこと' do
        expect(CsrfTokenService.verify(valid_token, valid_token)).to be true
      end
    end

    context '不一致トークンの場合' do
      let(:different_token) { CsrfTokenService.generate }

      it 'falseを返すこと' do
        expect(CsrfTokenService.verify(valid_token, different_token)).to be false
      end
    end

    context 'cookieトークンがnilの場合' do
      it 'falseを返すこと' do
        expect(CsrfTokenService.verify(nil, valid_token)).to be false
      end
    end

    context 'headerトークンがnilの場合' do
      it 'falseを返すこと' do
        expect(CsrfTokenService.verify(valid_token, nil)).to be false
      end
    end

    context '両方のトークンがnilの場合' do
      it 'falseを返すこと' do
        expect(CsrfTokenService.verify(nil, nil)).to be false
      end
    end

    context 'cookieトークンが空文字の場合' do
      it 'falseを返すこと' do
        expect(CsrfTokenService.verify('', valid_token)).to be false
      end
    end

    context 'headerトークンが空文字の場合' do
      it 'falseを返すこと' do
        expect(CsrfTokenService.verify(valid_token, '')).to be false
      end
    end

    context '両方のトークンが空文字の場合' do
      it 'falseを返すこと' do
        expect(CsrfTokenService.verify('', '')).to be false
      end
    end

    context '無効な形式のトークンの場合' do
      let(:invalid_token) { 'invalid_token_with_special_chars!' }

      it 'falseを返すこと' do
        expect(CsrfTokenService.verify(invalid_token, valid_token)).to be false
        expect(CsrfTokenService.verify(valid_token, invalid_token)).to be false
      end
    end

    context '長さが異なるトークンの場合' do
      let(:short_token) { 'short' }
      let(:long_token) { 'a' * 64 }

      it 'falseを返すこと' do
        expect(CsrfTokenService.verify(short_token, valid_token)).to be false
        expect(CsrfTokenService.verify(long_token, valid_token)).to be false
      end
    end
  end

  describe 'セキュリティ特性' do
    it 'タイミング攻撃に対して安全であること' do
      token = CsrfTokenService.generate
      wrong_token = CsrfTokenService.generate

      # 複数回実行して処理時間の一貫性を確認
      times = []
      10.times do
        start_time = Time.current
        CsrfTokenService.verify(token, wrong_token)
        times << (Time.current - start_time)
      end

      # 処理時間のばらつきが少ないことを確認（タイミング攻撃対策）
      avg_time = times.sum / times.length
      expect(times.all? { |t| (t - avg_time).abs < 0.001 }).to be true
    end

    it 'トークンの推測が困難であること' do
      tokens = 100.times.map { CsrfTokenService.generate }

      # 重複がないことを確認
      expect(tokens.uniq.length).to eq(100)

      # パターンが見つからないことを確認
      expect(tokens.any? { |t| t.include?('0000') }).to be false
      expect(tokens.any? { |t| t.include?('aaaa') }).to be false
    end
  end
end
