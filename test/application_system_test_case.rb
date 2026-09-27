require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ] do |options|
    # Der Kiosk löst den Verein über die Subdomain auf, aber
    # "verein.example.com" existiert nicht im DNS. Auf den lokalen Testserver
    # zeigen lassen, damit wir echte Subdomains im Browser testen können.
    options.add_argument("--host-resolver-rules=MAP *.example.com 127.0.0.1")
  end
end
