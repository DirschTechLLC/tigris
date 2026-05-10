class ApiKey < ApplicationRecord
  belongs_to :organization

  validates :name, presence: true
  validates :token_digest, presence: true, uniqueness: true
  validates :prefix, presence: true

  scope :active, -> { where(active: true) }

  def self.authenticate(raw_token)
    return nil if raw_token.blank?

    digest = Digest::SHA256.hexdigest(raw_token)
    key = active.find_by(token_digest: digest)
    key&.touch(:last_used_at)
    key
  end

  # Returns [ApiKey, raw_token]. raw_token is shown once and never stored.
  # Token format: tgk_<8 hex chars (prefix)><32 hex chars (secret)>
  def self.generate_for(organization, name:)
    prefix = "tgk_#{SecureRandom.hex(4)}"
    secret = SecureRandom.hex(16)
    raw = "#{prefix}#{secret}"
    key = organization.api_keys.create!(
      name: name,
      prefix: prefix,
      token_digest: Digest::SHA256.hexdigest(raw)
    )
    [ key, raw ]
  end

  def revoke!
    update!(active: false)
  end
end
