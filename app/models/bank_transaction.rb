class BankTransaction < ApplicationRecord
  belongs_to :bank_account

  validates :external_id, presence: true, uniqueness: true
  validates :amount_cents, presence: true
  validates :currency, presence: true

  delegate :organization, to: :bank_account

  def amount
    amount_cents / 100.0
  end

  def credit?
    amount_cents > 0
  end

  def debit?
    amount_cents < 0
  end
end
