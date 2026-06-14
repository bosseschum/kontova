class BankAccount < ApplicationRecord
  belongs_to :bank_connection

  validates :uid, presence: true, uniqueness: true
  validates :currency, presence: true

  delegate :organization, to: :bank_connection
end
