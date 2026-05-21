class Treasurer::SettingsController < Treasurer::BaseController
  def show
  end

  def update
    params[:settings].each do |key, value|
      Setting.set(key, value, organization: current_organization)
    end
    redirect_to treasurer_settings_path, notice: "Einstellungen gespeichert"
  end
end
