class Member < ApplicationRecord
  attr_reader :generated_password
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  before_validation :generate_password_if_member

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :organizations, through: :organization_memberships
  has_many :organization_memberships, dependent: :destroy
  has_many :transactions, dependent: :nullify
  has_many :purchases, dependent: :nullify
  has_many :inventory_counts, dependent: :nullify
  has_many :requests, dependent: :nullify

  def balance_cents
    transactions.not_sponsored.sum(:amount_cents)
  end

  def balance
    balance_cents / 100.0
  end

  def can_purchase?(amount_cents)
    balance_cents - amount_cents >= -5000
  end

  def treasurer?(organization)
    return true if admin?
    return false unless organization
    organization_memberships.find_by(organization: organization)&.treasurer?
  end

  def inventory_manager?(organization)
    return true if admin?
    return false unless organization
    organization_memberships.find_by(organization: organization)&.inventory_manager?
  end

  def member?(organization)
    role_for(organization) == "member"
  end

  def membership_for(organization)
    organization_memberships.find_by(organization: organization)
  end

  def role_for(organization)
    membership_for(organization)&.role
  end

  def pin_for(organization)
    membership_for(organization)&.pin
  end

  private

  def generate_password_if_member
    if password.blank?
      @generated_password = SecureRandom.hex(8)
      self.password = @generated_password
      self.password_confirmation = @generated_password
    end
  end
end
