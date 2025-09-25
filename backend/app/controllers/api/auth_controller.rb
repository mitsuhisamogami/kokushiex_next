module Api
  class AuthController < ApplicationController
    include JwtAuthenticatable
    skip_before_action :authenticate_request, only: [ :register, :login, :verify ]
    skip_before_action :verify_csrf_token, only: [ :register, :login, :verify ]

    # POST /api/auth/register
    def register
      user = User.new(user_params)
      user.is_guest = false

      if user.save
        token = encode_jwt({ user_id: user.id })
        render json: {
          user: user_response(user),
          token: token
        }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # POST /api/auth/login
    def login
      user = User.find_by(email: params[:email])

      if user && user.authenticate(params[:password])
        token = encode_jwt({ user_id: user.id })
        render json: {
          user: user_response(user),
          token: token
        }, status: :ok
      else
        render json: { error: "Invalid email or password" }, status: :unauthorized
      end
    end

    # POST /api/auth/logout
    def logout
      # JWTはステートレスなので、クライアント側でトークンを削除してもらう
      render json: { message: "Logged out successfully" }, status: :ok
    end

    # GET /api/auth/me
    def me
      if current_user
        authorize!(:edit_profile)
        render json: { user: user_response(current_user) }, status: :ok
      else
        render json: { error: "Not authenticated" }, status: :unauthorized
      end
    end

    # GET /api/auth/verify (Phase 1との互換性のため残す)
    def verify
      begin
        user = decode_jwt
        if user
          render json: {
            valid: true,
            user: user_response(user)
          }, status: :ok
        else
          render json: { valid: false }, status: :unauthorized
        end
      rescue JWT::ExpiredSignature, JWT::DecodeError
        render json: { valid: false }, status: :unauthorized
      end
    end

    private

    def user_params
      params.permit(:email, :password, :password_confirmation, :name)
    end

    def user_response(user)
      {
        id: user.id,
        email: user.email,
        name: user.name,
        is_guest: user.is_guest,
        role: user.role,
        created_at: user.created_at,
        updated_at: user.updated_at
      }
    end
  end
end
