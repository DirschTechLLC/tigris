class Organization < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :api_keys, dependent: :destroy
  has_many :submissions, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9\-]+\z/, message: "only lowercase letters, numbers, and hyphens" }

  before_validation :generate_slug, on: :create, if: -> { slug.blank? }

  def owner?(user)
    memberships.exists?(user: user, role: "owner")
  end

  def member?(user)
    memberships.exists?(user: user)
  end

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = name.to_s.downcase.gsub(/[^a-z0-9]+/, "-").delete_prefix("-").delete_suffix("-")
  end
end
