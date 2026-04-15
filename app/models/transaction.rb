class Transaction < ApplicationRecord
  belongs_to :member
  belongs_to :product, optional: true

  enum :kind, {
    drink_purchase: 0,
    deposit: 1,
    expense_reimbursement: 2,
    membership_fee: 3
  }

  validates :amount_cents, presence: true
  validates :quantity, numericality: { greater_than: 0 }
end
