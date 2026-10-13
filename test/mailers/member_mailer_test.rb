require "test_helper"

class MemberMailerTest < ActionMailer::TestCase
  test "welcome includes all credentials and the login link" do
    member = members(:one)
    organization = organizations(:one)

    mail = MemberMailer.welcome(member, "482913", "geheim123", organization)

    assert_equal [ member.email ], mail.to
    assert_equal "Willkommen bei Verein Eins!", mail.subject

    [ mail.text_part, mail.html_part ].each do |part|
      body = part.body.decoded
      assert_match member.email, body
      assert_match "geheim123", body
      assert_match "482913", body
      assert_match "#{organization.subdomain}.kontova.de", body
    end
  end

  test "welcome omits the password when none is provided" do
    member = members(:one)
    organization = organizations(:one)

    mail = MemberMailer.welcome(member, "482913", nil, organization)

    [ mail.text_part, mail.html_part ].each do |part|
      body = part.body.decoded
      refute_match "Passwort:", body
      assert_match member.email, body
      assert_match "482913", body
    end
  end
end
