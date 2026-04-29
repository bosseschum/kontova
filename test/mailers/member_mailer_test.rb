require "test_helper"

class MemberMailerTest < ActionMailer::TestCase
  test "invoice" do
    mail = MemberMailer.invoice
    assert_equal "Invoice", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
