class Transaction < ApplicationRecord
  belongs_to :organization
  belongs_to :member
  belongs_to :product, optional: true

  scope :sponsored, -> { where(sponsored: true) }
  scope :not_sponsored, -> { where(sponsored: false).or(where(sponsored: nil)) }

  enum :kind, {
    drink_purchase: 0,
    deposit: 1,
    expense_reimbursement: 2,
    membership_fee: 3
  }

  before_validation :set_default_quantity

  validates :amount_cents, presence: true
  validates :quantity, numericality: { greater_than: 0 }

  private

  def set_default_quantity
    self.quantity ||= 1
  end
end
