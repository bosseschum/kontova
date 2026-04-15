class Purchase < ApplicationRecord
  belongs_to :product
  belongs_to :member

  validates :quantity, :price_per_unit_cents, :purchased_on, presence: true
end
