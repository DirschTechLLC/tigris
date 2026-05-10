class Submission < ApplicationRecord
  belongs_to :organization
  belongs_to :api_key

  validates :payload, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
