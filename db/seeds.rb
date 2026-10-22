if Rails.env.development?
  organization = Organization.find_or_initialize_by(subdomain: "showcase")
  organization.update!(name: "KONTOVA Showcase", active: true)

  [
    { name: "Helles", price_cents: 250, crate_size: 20, crate_price_cents: 3000 },
    { name: "Weizen", price_cents: 300, crate_size: 20, crate_price_cents: 3600 },
    { name: "Radler", price_cents: 220, crate_size: 20, crate_price_cents: 2800 },
    { name: "Wasser", price_cents: 100, crate_size: 12, crate_price_cents: 900 }
  ].each do |attributes|
    product = organization.products.find_or_initialize_by(name: attributes[:name])
    product.update!(attributes.merge(active: true))
  end

  {
    "kasse@example.com" => {
      display_name: "Kassenwart",
      role: :treasurer,
      pin: "5678"
    },
    "mitglied@example.com" => {
      display_name: "Mitglied",
      role: :member,
      pin: "1234"
    }
  }.each do |email, attributes|
    member = Member.find_or_initialize_by(email: email)
    if member.new_record?
      member.password = "password"
      member.password_confirmation = "password"
    end
    member.update!(display_name: attributes[:display_name], super_admin: false)

    membership = organization.organization_memberships.find_or_initialize_by(member: member)
    membership.update!(
      role: attributes[:role],
      pin: attributes[:pin],
      pays_fee: false
    )
  end

  admin = Member.find_or_initialize_by(email: "admin@example.com")
  if admin.new_record?
    admin.password = "password"
    admin.password_confirmation = "password"
  end
  admin.update!(display_name: "Admin", super_admin: true)

  puts "Seeded showcase organization, products, and demo accounts (password: password)."
end
