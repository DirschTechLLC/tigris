module Api
  class BaseController < ActionController::API
    before_action :authenticate_api_key!

    private

    def authenticate_api_key!
      raw = request.headers["X-Api-Key"]
      @current_api_key = ApiKey.authenticate(raw)
      render json: { error: "Unauthorized" }, status: :unauthorized unless @current_api_key
    end

    def current_organization
      @current_api_key.organization
    end
  end
end
