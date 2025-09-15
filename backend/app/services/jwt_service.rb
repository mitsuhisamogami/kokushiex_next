class JwtService
  EXPIRATION_TIME = 24.hours

  def self.encode(payload)
    # expが既に設定されている場合はそれを使用、なければデフォルトの24時間を設定
    payload_with_exp = payload[:exp] ? payload : payload.merge(exp: EXPIRATION_TIME.from_now.to_i)
    JWT.encode(payload_with_exp, secret_key, "HS256")
  end

  def self.decode(token)
    # 無効なトークンや nil の場合は nil を返す
    return nil if token.nil? || token.empty?
    begin
      decoded =JWT.decode(token, secret_key, true, { algorithm: "HS256" })
      # decodeされたpayloadだけを返す
      decoded[0]
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    end
  end

  private

  def self.secret_key
    Rails.application.credentials.secret_key_base || "test_secret_key"
  end
end
