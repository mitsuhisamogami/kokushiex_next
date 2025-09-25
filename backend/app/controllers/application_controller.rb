class ApplicationController < ActionController::API
  include CsrfProtectable

  rescue_from AuthorizationService::UnauthorizedError, with: :handle_unauthorized

  protected

  def authenticate_request
    token = extract_token_from_header
    if token
      decoded_payload = JwtService.decode(token)
      if decoded_payload
        @current_user_id = decoded_payload["user_id"]
        @current_user = User.find_by(id: @current_user_id)

        # ゲストユーザーの期限チェック
        if @current_user&.is_guest && @current_user.guest_expired?
          render json: {
            error: "Guest session expired",
            message: "ゲストセッションの有効期限が切れました。再度ログインしてください。"
          }, status: :unauthorized
          nil
        end
      end
    end
  end

  def authenticate_user!
    authenticate_request
    unless current_user
      unauthorized_response
    end
  end

  def current_user
    @current_user
  end

  def current_user_id
    @current_user_id
  end

  def unauthorized_response
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def authorize!(action, resource = nil)
    authorization_service.authorize!(action, resource)
  end

  def permit?(action, resource = nil)
    authorization_service.permit?(action, resource)
  end

  private

  def authorization_service
    @authorization_service ||= AuthorizationService.new(current_user)
  end

  def handle_unauthorized(exception)
    render json: {
      error: "insufficient_permissions",
      message: exception.message,
      code: "AUTH_403",
      required_role: exception.required_role
    }, status: :forbidden
  end

  def extract_token_from_header
    if request.headers["Authorization"].present?
      request.headers["Authorization"]&.split(" ")&.last
    else
      nil
    end
  end
end
