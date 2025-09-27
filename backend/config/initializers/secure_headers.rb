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

  # Strict-Transport-Security (HSTS): HTTPS接続を強制
  # 段階的に導入（最初は短期間から開始）
  if Rails.env.production?
    # 本番環境: 最初は5分から開始（段階的に延長予定）
    # TODO: 動作確認後、以下の順序で延長
    # 5分(300) → 1時間(3600) → 1日(86400) → 1週間(604800) → 1ヶ月(2592000) → 1年(31536000)
    config.hsts = {
      max_age: 300,  # 5分（初期設定）
      include_subdomains: false,  # 最初はサブドメインを含めない
      preload: false  # プリロードは十分テスト後に有効化
    }
  else
    # 開発・テスト環境: HSTSを無効化（ローカルHTTPアクセスを許可）
    config.hsts = SecureHeaders::OPT_OUT
  end

  # セキュリティヘッダーが有効化されたことをログ出力
  Rails.logger.info "[SecureHeaders] Security headers initialized for #{Rails.env}"
  Rails.logger.info "[SecureHeaders] HSTS configuration: #{config.hsts.inspect}"
end
