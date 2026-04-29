class Treasurer::MembersController < Treasurer::BaseController
  def index
    @members = Member.order(:display_name)
  end

  def new
    @member = Member.new
  end

  def create
    @member = Member.new(member_params)
    if @member.save
      redirect_to treasurer_members_, notice: "Mitglied angelegt"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @member = Member.find(params[:id])
  end

  def update
    @member = Member.find(params[:id])

    update_params = member_params
    update_params = update_params.except(:password) if update_params[:password].blank?
    update_params = update_params.except(:pin) if update_params[:pin].blank?

    if @member.update(update_params)
      redirect_to treasurer_members_path, notice: "Mitglied aktualisiert"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def member_params
    params.require(:member).permit(:display_name, :email, :password, :pin, :role, :pays_fee, :lives_on_site)
  end
end
