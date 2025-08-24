class Api::HealthController < ApplicationController
  def check
    render json: {
      status: "ok",
      message: "KokushiEX API is running!",
      timestamp: Time.current
    }
  end
end
