class MixedCrate < ApplicationRecord
  has_many :mixed_crate_items, dependent: :destroy
  has_many :products, through: :mixed_crate_items

  scope :active, -> { where(active: true) }

  def price
    price_cents / 100.0
  end

  def total_quantity
    mixed_crate_items.sum(:quantity)
  end
end
