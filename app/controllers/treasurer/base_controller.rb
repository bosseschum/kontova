class Treasurer::BaseController < ApplicationController
  layout "treasurer"
  include Pundit::Authorization
  before_action :require_treasurer!

  private

  def require_treasurer!
    unless current_member.admin? || current_member.treasurer? && current_member.organization == current_organization
      redirect_to root_path, alert: "Kein Zugriff"
    end
  end
end
