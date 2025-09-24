# frozen_string_literal: true

SecureHeaders::Configuration.default do |config|
  # X-Frame-Options: クリックジャッキング防御
  config.x_frame_options = "DENY"

  # X-Content-Type-Options: MIMEタイプ推測防止
  config.x_content_type_options = "nosniff"

  # X-XSS-Protection: モダンブラウザではCSPが推奨されるため無効化
  config.x_xss_protection = "0"

  # X-Download-Options: IE8のファイル取り扱いに関する脆弱性対策
  config.x_download_options = "noopen"

  # X-Permitted-Cross-Domain-Policies: Flash/PDFなどのクロスドメインポリシー
  config.x_permitted_cross_domain_policies = "none"

  # Referrer-Policy: リファラ情報の制御
  config.referrer_policy = %w[strict-origin-when-cross-origin]

  # Content-Security-Policy (CSP)
  # APIサーバーなのでHTMLをレンダリングしないため、最小限の設定
  csp_config = if Rails.env.production?
                 {
                   default_src: %w['none'],
                   script_src: %w['none'],  # APIなのでスクリプト不要
                   frame_ancestors: %w['none'],
                   upgrade_insecure_requests: true
                 }
  else
                 # 開発・テスト環境
                 {
                   default_src: %w['none'],
                   script_src: %w['none'],  # APIなのでスクリプト不要
                   frame_ancestors: %w['none']
                 }
  end

  # CSPレポートURIが設定されている場合は追加
  if ENV["CSP_REPORT_URI"].present?
    csp_config[:report_uri] = [ ENV["CSP_REPORT_URI"] ]
  end

  config.csp = csp_config

  # セキュリティヘッダーが有効化されたことをログ出力
  Rails.logger.info "[SecureHeaders] Security headers initialized for #{Rails.env}"
end
