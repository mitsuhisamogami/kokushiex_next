class CsrfTokenService
  # 約32文字のURLセーフなランダム文字列を生成
  def self.generate
    SecureRandom.urlsafe_base64(24)
  end

  # 　トークンを安全に比較
  def self.verify(cookie_token, header_token)
    return false if cookie_token.blank? || header_token.blank?
    ActiveSupport::SecurityUtils.secure_compare(cookie_token, header_token)
  end
end
