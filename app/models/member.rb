class Member < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  before_create :generate_pin
  before_create :generate_password_if_member

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :pin, length: { is: 4 }, allow_nil: true, format: { with: /\A\d+\z/ }

  enum :role, { member: 0, treasurer: 1, inventory_manager: 2 }

  has_many :transactions, dependent: :nullify
  has_many :purchases, dependent: :nullify
  has_many :inventory_counts, dependent: :nullify

  def balance_cents
    transactions.sum(:amount_cents)
  end

  def balance
    balance_cents / 100.0
  end

  def can_purchase?(amount_cents)
    balance_cents - amount_cents >= -5000
  end

  def fee_amount_cents
    return 0 unless pays_fee?
    lives_on_site? ? Setting.get("fee_resident_cents", 5000).to_i : Setting.get("fee_standard_cents", 2500).to_i
  end

  def treasurer?
    admin? || role == "treasurer"
  end

  def inventory_manager?
    admin? || role == "inventory_manager"
  end

  private

  def generate_pin
    self.pin = rand(1000..9999).to_s
  end

  def generate_password_if_member
    if role == "member"
      self.password = SecureRandom.hex(16)
    end
  end
end
