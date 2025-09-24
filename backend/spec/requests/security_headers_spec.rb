# frozen_string_literal: true

require "rails_helper"

RSpec.describe "SecurityHeaders", type: :request do
  describe "Security headers on API responses" do
    before do
      get "/api/health"
    end

    it "sets X-Frame-Options header" do
      expect(response.headers["X-Frame-Options"]).to eq("DENY")
    end

    it "sets X-Content-Type-Options header" do
      expect(response.headers["X-Content-Type-Options"]).to eq("nosniff")
    end

    it "sets X-XSS-Protection header to disabled" do
      expect(response.headers["X-XSS-Protection"]).to eq("0")
    end

    it "sets X-Download-Options header" do
      expect(response.headers["X-Download-Options"]).to eq("noopen")
    end

    it "sets X-Permitted-Cross-Domain-Policies header" do
      expect(response.headers["X-Permitted-Cross-Domain-Policies"]).to eq("none")
    end

    it "sets Referrer-Policy header" do
      expect(response.headers["Referrer-Policy"]).to eq("strict-origin-when-cross-origin")
    end

    it "sets Content-Security-Policy header" do
      csp = response.headers["Content-Security-Policy"]
      expect(csp).to include("default-src 'none'")
      expect(csp).to include("frame-ancestors 'none'")
    end
  end

  describe "Security headers on different endpoints" do
    it "applies headers to auth endpoints" do
      post "/api/auth/login", params: { email: "test@example.com", password: "password" }

      expect(response.headers["X-Frame-Options"]).to eq("DENY")
      expect(response.headers["X-Content-Type-Options"]).to eq("nosniff")
    end

    it "applies headers to guest session endpoints" do
      post "/api/guest_sessions"

      expect(response.headers["X-Frame-Options"]).to eq("DENY")
      expect(response.headers["X-Content-Type-Options"]).to eq("nosniff")
    end
  end

  describe "Production-specific headers", if: Rails.env.production? do
    before do
      get "/api/health"
    end

    it "includes upgrade-insecure-requests in CSP" do
      csp = response.headers["Content-Security-Policy"]
      expect(csp).to include("upgrade-insecure-requests")
    end
  end

  describe "CSP Report URI", if: ENV["CSP_REPORT_URI"].present? do
    before do
      ENV["CSP_REPORT_URI"] = "https://example.com/csp-reports"

      # Reload SecureHeaders configuration
      load Rails.root.join("config/initializers/secure_headers.rb")

      get "/api/health"
    end

    after do
      ENV.delete("CSP_REPORT_URI")

      # Reload SecureHeaders configuration
      load Rails.root.join("config/initializers/secure_headers.rb")
    end

    it "includes report-uri in CSP when environment variable is set" do
      csp = response.headers["Content-Security-Policy"]
      expect(csp).to include("report-uri https://example.com/csp-reports")
    end
  end
end
