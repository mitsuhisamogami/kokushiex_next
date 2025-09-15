module JwtAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
  end

  private

  def authenticate_request
    @current_user = decode_jwt
  rescue JWT::ExpiredSignature
    render json: { error: "Token has expired" }, status: :unauthorized
  rescue JWT::DecodeError
    render json: { error: "Invalid token" }, status: :unauthorized
  end

  def current_user
    @current_user
  end

  def encode_jwt(payload)
    payload[:exp] = 24.hours.from_now.to_i
    JWT.encode(payload, jwt_secret_key, "HS256")
  end

  def decode_jwt
    token = extract_token_from_header
    return nil unless token

    decoded = JWT.decode(token, jwt_secret_key, true, algorithm: "HS256").first
    User.find(decoded["user_id"])
  end

  def extract_token_from_header
    authorization_header = request.headers["Authorization"]
    return nil unless authorization_header

    authorization_header.split(" ").last
  end

  def jwt_secret_key
    Rails.application.credentials.jwt_secret_key || ENV["JWT_SECRET_KEY"] || "development_secret_key"
  end
end
