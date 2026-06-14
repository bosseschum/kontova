module EnableBanking
  class AuthorizationService
    def initialize(bank:, redirect_url:)
      @bank = bank
      @redirect_url = redirect_url
    end

    def call
      EnableBanking::Client.new.post(
        "/auth",
        {
          access: {
            valid_until: 90.days.from_now.iso8601
          },
          aspsp: {
            name: @bank["name"],
            country: @bank["country"]
          },
          state: SecureRandom.uuid,
          redirect_url: @redirect_url,
          psu_type: "business"
        }
      )
    end
  end
end
