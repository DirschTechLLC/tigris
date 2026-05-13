class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  validates :name, presence: true
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
