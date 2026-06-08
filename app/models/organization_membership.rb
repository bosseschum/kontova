class OrganizationMembership < ApplicationRecord
  belongs_to :member
  belongs_to :organization

  enum :role, { member: 0, treasurer: 1, inventory_manager: 2 }

  validates :pin, length: { is: 4 }, allow_nil: true,
                  format: { with: /\A\d+\z/ }

  def fee_amount_cents
    return 0 unless pays_fee?
    lives_on_site? ?
      Setting.get("fee_resident_cents", "3000", organization: organization).to_i :
      Setting.get("fee_standard_cents", "2500", organization: organization).to_i
  end
end
