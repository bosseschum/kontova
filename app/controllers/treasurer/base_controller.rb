class Treasurer::BaseController < ApplicationController
  layout "treasurer"
  include Pundit::Authorization
  before_action :require_treasurer!

  def current_member
    @current_member ||= warden.authenticate(scope: :member)
  end
  helper_method :current_member

  private

  def require_treasurer!
    redirect_to root_path, alert: "Kein Zugriff" unless current_member.treasurer?
  end
end
