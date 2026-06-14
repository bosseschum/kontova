require "jwt"
require "openssl"
require "net/http"
require "json"

module EnableBanking
  class Client
    BASE_URL = "https://api.enablebanking.com"

    def initialize
      @application_id = Rails.application.credentials
      .dig(:enable_banking, :application_id)

      key_path = Rails.application.credentials
      .dig(:enable_banking, :private_key_path)

      @private_key = OpenSSL::PKey.read(
        File.read(Rails.root.join(key_path))
      )
    end

    def get(path)
      uri = URI("#{BASE_URL}#{path}")

      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/json"
      request["Authorization"] = "Bearer #{JwtToken.generate}"

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      JSON.parse(response.body)
    end
  end
end
