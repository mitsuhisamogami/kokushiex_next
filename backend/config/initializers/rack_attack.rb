# frozen_string_literal: true

# Rate limiting configuration using Rack::Attack
#
# This configuration implements the security requirements from Issue #45:
# - Login attempts: 5/minute, 20/hour
# - API calls: 100/minute (authenticated), 50/minute (unauthenticated)
# - Guest user creation: 3/hour

class Rack::Attack
  # Enable rate limiting only if configured (default: true in production, test, and development)
  Rack::Attack.enabled = ENV.fetch("RATE_LIMIT_ENABLED", true).to_s.in?(%w[true 1])

  # Configure cache store (Redis recommended for production)
  if Rails.env.development? || Rails.env.test?
    # Use memory store for development and test (simpler setup)
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  else
    # Use Redis for production/staging (persistent and scalable)
    redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/1")
    Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: redis_url)
  end

  # =======================
  # Rate Limiting Rules
  # =======================

  # 1. Login attempts - IP + email combination
  # 5 attempts per minute
  throttle("login/ip+email/minute", limit: ENV.fetch("RATE_LIMIT_LOGIN_PER_MINUTE", 5).to_i, period: 1.minute) do |req|
    if req.path == "/api/auth/login" && req.post?
      email = req.params["email"] || "unknown"
      "#{req.ip}:#{email}"
    end
  end

  # 20 attempts per hour
  throttle("login/ip+email/hour", limit: ENV.fetch("RATE_LIMIT_LOGIN_PER_HOUR", 20).to_i, period: 1.hour) do |req|
    if req.path == "/api/auth/login" && req.post?
      email = req.params["email"] || "unknown"
      "#{req.ip}:#{email}"
    end
  end

  # 2. API calls - authenticated users
  throttle("api/authenticated", limit: ENV.fetch("RATE_LIMIT_API_PER_MINUTE", 100).to_i, period: 1.minute) do |req|
    if req.path.start_with?("/api/") && req.env["HTTP_AUTHORIZATION"].present?
      # Extract user_id from JWT token for authenticated requests
      begin
        token = req.env["HTTP_AUTHORIZATION"]&.split(" ")&.last
        if token
          payload = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: "HS256" })
          user_id = payload.first["user_id"]
          "user:#{user_id}"
        end
      rescue JWT::DecodeError, JWT::ExpiredSignature
        # Token invalid, treat as unauthenticated
        nil
      end
    end
  end

  # 3. API calls - unauthenticated users (by IP)
  throttle("api/unauthenticated", limit: ENV.fetch("RATE_LIMIT_API_UNAUTH_PER_MINUTE", 50).to_i, period: 1.minute) do |req|
    if req.path.start_with?("/api/") && req.env["HTTP_AUTHORIZATION"].blank?
      req.ip
    end
  end

  # 4. Guest user creation
  throttle("guest_creation/ip", limit: ENV.fetch("RATE_LIMIT_GUEST_PER_HOUR", 3).to_i, period: 1.hour) do |req|
    if req.path == "/api/guest_sessions" && req.post?
      req.ip
    end
  end

  # =======================
  # Custom Response
  # =======================

  # Customize the response when rate limit is exceeded
  self.throttled_responder = lambda do |_env|
    retry_after = 60 # Default retry after 60 seconds

    headers = {
      "Content-Type" => "application/json",
      "Retry-After" => retry_after.to_s
    }

    body = {
      error: "rate_limit_exceeded",
      message: "リクエスト数が上限に達しました。しばらく待ってから再試行してください。",
      code: "RATE_LIMIT_001",
      retry_after: retry_after
    }.to_json

    [ 429, headers, [ body ] ]
  end

  # =======================
  # Logging and Monitoring
  # =======================

  # Log rate limit hits
  ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _request_id, payload|
    request = payload[:request]
    matched = payload[:matched]

    Rails.logger.warn "[Rate Limit] #{matched} triggered for IP: #{request.ip}, " \
                     "Path: #{request.path}, Method: #{request.request_method}"
  end

  # Log blocklist/allowlist hits if configured
  ActiveSupport::Notifications.subscribe("blocklist.rack_attack") do |_name, _start, _finish, _request_id, payload|
    request = payload[:request]
    Rails.logger.warn "[Rate Limit] Blocked request from IP: #{request.ip}, Path: #{request.path}"
  end
end
