module ApiKeyHelpers
  def api_post(path, raw_token:, params: {})
    post path, params: params, headers: { "X-Api-Key" => raw_token }, as: :json
  end
end

RSpec.configure do |config|
  config.include ApiKeyHelpers, type: :request
end
