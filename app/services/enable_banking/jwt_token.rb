require "jwt"
require "openssl"

module EnableBanking
  class JwtToken
    def self.generate
      application_id =
        Rails.application.credentials.dig(
          :enable_banking,
          :application_id
        )

      key_path =
        Rails.application.credentials.dig(
          :enable_banking,
          :private_key_path
        )

      private_key =
        OpenSSL::PKey::RSA.new(
          File.read(Rails.root.join(key_path))
        )

      now = Time.now.to_i

      payload = {
        iss: "enablebanking.com",
        aud: "api.enablebanking.com",
        iat: now,
        exp: now + 3600
      }

      headers = {
        typ: "JWT",
        alg: "RS256",
        kid: application_id
      }

      JWT.encode(
        payload,
        private_key,
        "RS256",
        headers
      )
    end
  end
end
