FactoryBot.define do
  factory :submission do
    organization
    api_key
    payload { { "email" => "submitter@example.com", "name" => "Test User", "message" => "Hello" } }
    remote_ip { "1.2.3.4" }
    user_agent { "Mozilla/5.0" }
    referrer { "https://example.com/contact" }
  end
end
