class Member < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { member: 0, treasurer: 1, inventory_manager: 2 }

  has_many :transactions
  has_many :purchases
  has_many :inventory_counts

  def balance_cents
    transactions.sum(:amount_cents)
  end

  def balance
    balance_cents / 100.0
  end

  def can_purchase?
    balance_cents - amount_cents >= -5000
  end
end
