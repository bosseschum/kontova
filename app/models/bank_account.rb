class BankAccount < ApplicationRecord
  belongs_to :bank_connection
  has_many :bank_transactions, dependent: :destroy

  validates :uid, presence: true, uniqueness: true
  validates :currency, presence: true

  delegate :organization, to: :bank_connection
end
