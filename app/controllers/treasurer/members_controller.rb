class Treasurer::MembersController < Treasurer::BaseController
  def index
    @members = current_organization.members.order(:display_name)
  end

  def new
    @member = current_organization.members.new
  end

  def create
    @member = current_organization.members.new(member_params)

    if @member.role == "member" && member_params[:password].blank?
      @member.password = SecureRandom.hex(16)
    end

    if @member.save
      MemberMailer.welcome(@member, @member.pin).deliver_later
      redirect_to treasurer_members_path, notice: "Mitglied angelegt - PIN wurde verschickt"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @member = current_organization.members.find(params[:id])
  end

  def update
    @member = current_organization.members.find(params[:id])

    update_params = member_params
    update_params = update_params.except(:password) if update_params[:password].blank?
    update_params = update_params.except(:pin) if update_params[:pin].blank?

    if @member.update(update_params)
      redirect_to treasurer_members_path, notice: "Mitglied aktualisiert"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @member = current_organization.members.find(params[:id])
    @member.destroy
    redirect_to treasurer_members_path, notice: "Mitglied gelöscht"
  end

  private

  def member_params
    params.require(:member).permit(:display_name, :email, :password, :pin, :role, :pays_fee, :lives_on_site)
  end
end
