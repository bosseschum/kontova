module Treasurer
  class BankConnectionsController < Treasurer::BaseController
    def new
      begin
        @banks = EnableBanking::Client.new.banks
      rescue RuntimeError => e
        Rails.logger.error("Enable Banking banks fetch failed: #{e.message}")
        @banks = []
        flash.now[:alert] = "Bankliste konnte nicht geladen werden: #{e.message}"
      end
    end

    def create
      bank = EnableBanking::Client.new.banks.find { |b| b["name"] == params[:bank_name] }
      return redirect_to treasurer_root_path, alert: "Bank nicht gefunden." unless bank

      result = EnableBanking::AuthorizationService.new(
        organization: current_organization,
        bank: bank,
        redirect_url: banking_callback_url(host: Rails.application.config.default_url_options[:host])
      ).call

      redirect_to result["url"], allow_other_host: true
    end

    def destroy
      current_organization.bank_connection&.destroy
      redirect_to treasurer_root_path, notice: "Bankverbindung getrennt."
    end

    private

    def require_treasurer!
      unless current_member.treasurer?(current_organization) || current_member.admin?
        redirect_to treasurer_root_path, alert: "Kein Zugriff."
      end
    end
  end
end
