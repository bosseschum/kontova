class Treasurer::TransactionsController < Treasurer::BaseController
  def index
    @transactions = Transaction.joins(:member)
      .where(members: { organization: current_organization })
      .includes(:member, :product)
      .order(created_at: :desc)
      .limit(100)

    if params[:member_id].present?
      @transactions = @transactions.where(member_id: params[:member_id])
      @member = current_organization.members.find(params[:member_id])
    end
  end

  def new
    @transaction = Transaction.new
    @members     = current_organization.members.order(:display_name)
  end

  def create
    @transaction = Transaction.new(transaction_params)
    @transaction.organization = current_organization
    if @transaction.save
      redirect_to treasurer_transactions_path, notice: "Transaktion gebucht"
    else
      @members = current_organization.members.order(:display_name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @transaction = Transaction.joins(:member)
      .where(members: { organization: current_organization })
      .find(params[:id])
    @members = current_organization.members.order(:display_name)
  end

  def update
    @transaction = Transaction.joins(:member)
      .where(members: { organization: current_organization })
      .find(params[:id])

    if @transaction.update(transaction_params)
      redirect_to treasurer_transactions_path, notice: "Transaktion aktualisiert"
    else
      @members = current_organization.members.order(:display_name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @transaction = Transaction.joins(:member)
      .where(members: { organization: current_organization })
      .find(params[:id])
    @transaction.destroy
    redirect_to treasurer_transactions_path, notice: "Transaktion gelöscht"
  end

  private

  def transaction_params
    params.require(:transaction).permit(
      :member_id, :amount_cents, :kind, :note
    )
  end
end
