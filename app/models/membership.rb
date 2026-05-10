class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  validates :role, inclusion: { in: %w[owner member] }
  validates :user_id, uniqueness: { scope: :organization_id, message: "is already a member of this organization" }

  scope :owners, -> { where(role: "owner") }
  scope :members, -> { where(role: "member") }
end
