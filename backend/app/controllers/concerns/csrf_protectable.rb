module CsrfProtectable
  extend ActiveSupport::Concern
  included do
    before_action :verify_csrf_token
    after_action :set_csrf_token_response, if: -> { @csrf_token_for_response }
  end

  private

  def verify_csrf_token
    return unless csrf_protected_action?

    cookie_token = extract_csrf_token_from_cookie
    header_token = extract_csrf_token_from_header

    if CsrfTokenService.verify(cookie_token, header_token)
      @csrf_token_for_response = CsrfTokenService.generate
    else
      csrf_token_invalid
    end
  end

  def csrf_protected_action?
    current_action = params[:action]
    current_method = request.method

    (current_method == "POST" || current_method == "PUT" || current_method == "PATCH" || current_method == "DELETE") ||
    (current_action == "logout" && current_method == "GET")
  end

  def extract_csrf_token_from_cookie
    request.cookies["_csrf_token"]
  end

  def extract_csrf_token_from_header
    request.headers["X-CSRF-Token"]
  end

  def set_csrf_token_cookie(token)
    response.set_cookie("_csrf_token",
      value: token,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :strict
    )
  end

  def set_csrf_token_response
    token = @csrf_token_for_response
    return unless token

    # Cookieに設定
    set_csrf_token_cookie(token)

    # レスポンスヘッダーにトークンを設定
    response.headers["X-CSRF-Token"] = token

    # レスポンスボディがJSONの場合、トークンを追加
    if response.content_type&.include?("application/json")
      begin
        body = JSON.parse(response.body)
        body["csrf_token"] = token
        response.body = body.to_json
      rescue JSON::ParserError
        # JSONでない場合はスキップ
      end
    end
  end

  def csrf_token_invalid
    render json: { error: "Invalid CSRF token" }, status: :forbidden
  end
end
