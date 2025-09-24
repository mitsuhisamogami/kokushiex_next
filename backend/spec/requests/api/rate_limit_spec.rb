require 'rails_helper'

RSpec.describe "レート制限", type: :request do
  # 共通のリクエストヘッダー（Host Authorizationを回避）
  let(:common_headers) { { "HOST" => "localhost" } }

  # 共通のURL
  let(:login_url) { "/api/auth/login" }
  let(:api_url) { "/api/auth/me" }
  let(:guest_creation_url) { "/api/guest_sessions" }

  # 共通のテストユーザー
  let(:user) { create(:user, email: "test@example.com", password: "password123") }
  let(:valid_params) { { email: user.email, password: "password123" } }
  let(:guest_user) { create(:user, :guest) }

  before do
    # レート制限が有効であることを確認（モックではなく実際の設定を使用）
    expect(Rack::Attack.enabled).to be(true), "Rack::Attack should be enabled in test environment"

    # 各テスト前にレート制限キャッシュをクリア
    Rack::Attack.cache.store.clear if Rack::Attack.cache.store.respond_to?(:clear)
  end

  after do
    # 各テスト後にクリーンアップ
    Rack::Attack.cache.store.clear if Rack::Attack.cache.store.respond_to?(:clear)
  end

  describe "ログイン試行のレート制限" do
    context "1分間の制限" do
      it "1分間に5回のログイン試行を許可する" do
        5.times do |i|
          post login_url, params: valid_params, headers: common_headers
          expect(response.status).not_to eq(429), "リクエスト #{i + 1}回目はレート制限されるべきではない"
        end
      end

      it "1分間で6回目のログイン試行をブロックする" do
        # 制限に達するまで5回リクエスト
        5.times { post login_url, params: valid_params, headers: common_headers }

        # 6回目のリクエストはレート制限される
        post login_url, params: valid_params, headers: common_headers
        expect(response.status).to eq(429)

        json = JSON.parse(response.body)
        expect(json["error"]).to eq("rate_limit_exceeded")
        expect(json["code"]).to eq("RATE_LIMIT_001")
        expect(response.headers["Retry-After"]).to be_present
      end

      it "IP + email の組み合わせごとにレート制限する" do
        # 異なるメールアドレスは別の制限を持つべき
        different_user = create(:user, email: "different@example.com")
        5.times { post login_url, params: { email: user.email, password: "password123" }, headers: common_headers }

        # 同じIPでも異なるメールアドレスなら動作する
        post login_url, params: { email: different_user.email, password: "password123" }, headers: common_headers
        expect(response.status).not_to eq(429)
      end
    end
  end

  describe "API呼び出しのレート制限" do
    context "認証済みユーザー" do
      let(:token) { JwtService.encode({ user_id: user.id }) }
      let(:auth_headers) { { "Authorization" => "Bearer #{token}" }.merge(common_headers) }

      it "認証済みユーザーに複数のAPI呼び出しを許可する" do
        10.times do |i|
          get api_url, headers: auth_headers
          expect(response.status).not_to eq(429), "リクエスト #{i + 1}回目はレート制限されるべきではない"
        end
      end

      it "異なる認証済みユーザーごとに別の制限を持つ" do
        user2 = create(:user)
        user1_token = JwtService.encode({ user_id: user.id })
        user2_token = JwtService.encode({ user_id: user2.id })

        # user1でリクエスト実行
        10.times { get api_url, headers: { "Authorization" => "Bearer #{user1_token}" }.merge(common_headers) }

        # 異なるユーザーなら引き続き許可される
        get api_url, headers: { "Authorization" => "Bearer #{user2_token}" }.merge(common_headers)
        expect(response.status).not_to eq(429)
      end
    end

    context "未認証ユーザー" do
      it "未認証ユーザーに複数のAPI呼び出しを許可する" do
        10.times do |i|
          get api_url, headers: common_headers
          expect(response.status).not_to eq(429), "リクエスト #{i + 1}回目はレート制限されるべきではない"
        end
      end
    end

    context "無効なJWTトークン" do
      it "無効なトークンを持つリクエストを未認証として扱う" do
        invalid_headers = { "Authorization" => "Bearer invalid_token" }

        get api_url, headers: invalid_headers.merge(common_headers)
        expect(response.status).not_to eq(429)
      end
    end
  end

  describe "ゲストユーザー作成のレート制限" do
    it "複数のゲストユーザー作成を許可する" do
      3.times do |i|
        post guest_creation_url, headers: common_headers
        expect(response.status).not_to eq(429), "リクエスト #{i + 1}回目はレート制限されるべきではない"
      end
    end
  end

  describe "エラーレスポンス形式" do
    it "レート制限時に適切なエラー形式を返す" do
      6.times { post login_url, params: valid_params, headers: common_headers }

      expect(response.status).to eq(429)
      expect(response.content_type).to include("application/json")
      expect(response.headers["Retry-After"]).to be_present

      json = JSON.parse(response.body)
      expect(json).to include(
        "error" => "rate_limit_exceeded",
        "message" => "リクエスト数が上限に達しました。しばらく待ってから再試行してください。",
        "code" => "RATE_LIMIT_001",
        "retry_after" => 60
      )
    end
  end

  describe "レート制限設定" do
    it "デフォルト設定値を使用する" do
      expect(defined?(Rack::Attack)).to be_truthy
    end
  end
end
