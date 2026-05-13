class Organization < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :api_keys, dependent: :destroy
  has_many :submissions, dependent: :destroy

  validates :name, presence: true

  def owner?(user)
    memberships.owner.exists?(user: user)
  end

  def member?(user)
    memberships.exists?(user: user)
  end
end
