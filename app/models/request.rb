class Request < ApplicationRecord
  belongs_to :member
  has_one_attached :receipt

  enum :kind, {
    expense: 0,
    other: 1
  }

  enum :status, {
    pending: 0,
    approved: 1,
    rejected: 2
  }

  validates :description, presence: true
  validates :amount_cents, presence: true, if: :expense?
end
