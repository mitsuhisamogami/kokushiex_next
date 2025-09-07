class ApplicationController < ActionController::API
  protected

  def authenticate_request
    # TODO(human): リクエストヘッダーからトークンを取得し、JwtServiceでデコードして認証を行う
    # Authorization: Bearer <token> 形式のヘッダーからトークンを抽出
    # 有効なトークンの場合は @current_user_id を設定
    # 無効な場合は unauthorized_response を呼び出す
    token = extract_token_from_header
    if token
      decoded_payload = JwtService.decode(token)
      if decoded_payload
        @current_user_id = decoded_payload["user_id"]
      end
    end
  end

  def current_user_id
    @current_user_id
  end

  def unauthorized_response
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  private

  def extract_token_from_header
    # TODO(human): Authorization ヘッダーから Bearer トークンを抽出する実装
    # "Bearer <token>" 形式から <token> 部分のみを返す
    if request.headers["Authorization"].present?
      request.headers["Authorization"]&.split(" ")&.last
    else
      nil
    end
  end
end
