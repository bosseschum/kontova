class Product < ApplicationRecord
  has_many :transactions
  has_many :purchases
  has_many :inventory_counts

  scope :active, -> { where(active: true) }

  def price
    price_cents / 100.0
  end

  def total_purchased
    purchases.sum(:quantity)
  end

  def total_sold
    transactions.where(kind: :drink_purchase).sum(:quantity)
  end

  def expected_stock
        total_purchased - total_sold
  end

  def last_count
    inventory_counts.order(:counted_on).last
  end

  def stock_discrepancy
    return nil unless last_count
    last_count.actual_quantity - expected_stock
  end
end
