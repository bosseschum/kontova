module EnableBanking
  class AuthorizationService
    def initialize(organization:, bank:, redirect_url:)
      @organization = organization
      @bank = bank
      @redirect_url = redirect_url
    end

    def call
      state = SecureRandom.uuid

      @result = EnableBanking::Client.new.post(
        "/auth",
        {
          access: {
            valid_until: 90.days.from_now.iso8601
          },
          aspsp: {
            name: @bank["name"],
            country: @bank["country"]
          },
          state: state,
          redirect_url: @redirect_url,
          psu_type: "business"
        }
      )

      @organization.create_bank_connection!(
        authorization_id: state,
        bank_name: @bank["name"],
        bic: @bank["bic"],
        consent_expires_at: 90.days.from_now
      )

      @result
    end
  end
end
