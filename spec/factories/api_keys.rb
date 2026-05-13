FactoryBot.define do
  factory :api_key do
    organization
    sequence(:name) { |n| "Key #{n}" }
    prefix { "tgk_#{SecureRandom.hex(4)}" }
    token_digest { Digest::SHA256.hexdigest(SecureRandom.hex(32)) }
    active { true }

    trait :revoked do
      active { false }
    end
  end
end
