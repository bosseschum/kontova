class InventoryCount < ApplicationRecord
  belongs_to :product
  belongs_to :member

  validates :actual_quantity, :counted_on, presence: true
end
