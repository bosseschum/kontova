class Treasurer::GuestAccessesController < Treasurer::BaseController
  def index
    @guests = current_organization.guest_accesses.active
  end

  def new
    @guest = GuestAccess.new
  end

  def create
    @guest = current_organization.guest_accesses.new(guest_access_params)
    if @guest.save
      redirect_to treasurer_guest_accesses_path, notice: "Gastzugang erstellt - PIN: #{@guest.pin}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def guest_access_params
    params.require(:guest_access).permit(:display_name, :email, :expires_at)
  end
end
