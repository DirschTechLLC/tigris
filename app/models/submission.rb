class Submission < ApplicationRecord
  belongs_to :organization
  belongs_to :api_key

  validates :payload, presence: true
  validate :payload_contains_email

  scope :recent, -> { order(created_at: :desc) }

  private

  def payload_contains_email
    errors.add(:payload, :missing_email) unless payload&.key?("email")
  end
end
