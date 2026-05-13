class Rack::Attack
  throttle("api/submissions/by_key", limit: 60, period: 1.minute) do |request|
    if request.path.start_with?("/api/v1/submissions") && request.post?
      request.get_header("HTTP_X_API_KEY")&.slice(0, 12)
    end
  end

  throttle("api/submissions/by_ip", limit: 120, period: 1.minute) do |request|
    request.ip if request.path.start_with?("/api/v1/submissions") && request.post?
  end

  self.throttled_responder = lambda do |env|
    req = Rack::Request.new(env)
    if req.path.start_with?("/api/")
      [429, { "Content-Type" => "application/json" }, [{ error: "Rate limit exceeded." }.to_json]]
    else
      [429, { "Content-Type" => "text/html" }, ["Rate limit exceeded."]]
    end
  end
end
