module Api
  class AuthController < ApplicationController
    # Phase 1では基本的な認証インフラのみ実装（実際のユーザー認証は後のフェーズ）

    def login
      # TODO(human): 認証ロジックを実装
      # Phase 1では仮のユーザーで動作確認
      # email/passwordを受け取り、正しければJWTトークンを返す

      # パラメータの存在チェック（400 Bad Request）
      if params[:email].blank? || params[:password].blank?
        render json: { error: "Email and password are required" }, status: :bad_request
        return
      end

      # 認証チェック（401 Unauthorized）
      if params[:email] == "test@example.com" && params[:password] == "password123"
        token = JwtService.encode({ user_id: 1, email: params[:email] })
        render json: {
          token: token,
          user: { id: 1, email: params[:email] }
        }, status: :ok
      else
        render json: { error: "Invalid email or password" }, status: :unauthorized
      end
    end

    def verify
      # Authorizationヘッダーのトークンを検証
      # 有効なら { valid: true, user: {...} } を返す
      # 無効なら { valid: false } を返す
      authenticate_request  #
      # pplicationControllerのメソッドを使用

      if @current_user_id
        render json: {
          valid: true,
          user: { id: @current_user_id }
        }, status: :ok
      else
        render json: { valid: false }, status: :unauthorized
      end
    end

    private

    def login_params
      params.permit(:email, :password)
    end
  end
end
