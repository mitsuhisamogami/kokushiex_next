class Api::GuestSessionsController < ApplicationController
  include JwtAuthenticatable
  skip_before_action :authenticate_request, only: [ :create ]

  def create
    begin
      guest_user = User.create_guest_user

      # JWTトークンを生成（ゲストユーザー用のスコープ付き）
      token = generate_guest_token(guest_user)

      render json: {
        status: "success",
        data: {
          user: {
            id: guest_user.id,
            is_guest: true,
            expires_at: guest_user.guest_expires_at,
            remaining_seconds: guest_user.guest_remaining_seconds,
            remaining_time: guest_user.guest_remaining_time
          },
          token: token
        },
        message: "ゲストユーザーとしてログインしました"
      }, status: :created
    rescue StandardError => e
      render json: {
        status: "error",
        message: e.message
      }, status: :unprocessable_entity
    end
  end

  private

  def generate_guest_token(user)
    payload = {
      user_id: user.id,
      is_guest: true,
      exp: 24.hours.from_now.to_i
    }
    JwtService.encode(payload)
  end
end
