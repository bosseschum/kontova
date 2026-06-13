class LandingController < ApplicationController
  skip_before_action :authenticate_member!
  skip_before_action :set_organization

  def index
  end

  def contact
    name = params[:name]
    email = params[:email]
    message = params[:message]

    LandingMailer.contact(name, email, message).deliver_later
    redirect_to root_path, notice: "Nachricht gesendet! Wir melden uns bald."
  end
end
