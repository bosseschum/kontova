class Purchase < ApplicationRecord
  belongs_to :organization
  belongs_to :product
  belongs_to :member

  validates :quantity, :purchased_on, presence: true
end
