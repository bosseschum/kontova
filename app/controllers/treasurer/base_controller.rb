class Treasurer::BaseController < ApplicationController
  layout "treasurer"
  include Pundit::Authorization
  before_action :require_treasurer!

  private

  def require_treasurer!
    redirect_to root_path, alert: "Kein Zugriff" unless current_member.treasurer?
  end
end
