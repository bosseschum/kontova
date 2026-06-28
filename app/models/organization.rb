class Organization < ApplicationRecord
  has_many :organization_memberships
  has_many :members, through: :organization_memberships
  has_many :guest_accesses, dependent: :destroy
  has_many :products
  has_many :transactions, through: :members
  has_many :purchases
  has_many :inventory_counts
  has_many :requests, through: :members
  has_many :settings

  has_one :bank_connection, dependent: :destroy
  has_many :bank_accounts, through: :bank_connection

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true,
    format: { with: /\A[a-z0-9-]+\z/, message: "nur Kleinbuchstaben, Zahlen und Bindestriche sind erlaubt" }

  scope :active, -> { where(active: true) }
end
