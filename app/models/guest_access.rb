class GuestAccess < ApplicationRecord
  belongs_to :organization
  has_many :transactions, as: :purchaser, dependent: :destroy

  validates :display_name, presence: true
  validates :email, presence: true
  validates :pin, lenght: { is: 4 }, format: { with: /\A\d+\z/ }

  scope :active, -> { where("expires_at > ?", Time.current).where(invoiced: false) }
  scope :expired_uninvoiced, -> { where("expires_at <= ?", Time.current).where(invoiced: false) }

  before_create :generate_pin, unless: :pin

  def balance_cents
    transactions.sum(:amount_cents)
  end

  def total_spent_cents
    -balance_cents
  end

  private

  def generate_pin
    self.pin = rand(1000..9999).to_s
  end
end
