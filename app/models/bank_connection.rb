class BankConnection < ApplicationRecord
  belongs_to :organization
  has_many :bank_accounts, dependent: :destroy

  validates :authorization_id, presence: true, uniqueness: true
  validates :bank_name, presence: true
end
