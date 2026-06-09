class Treasurer::TransactionsController < Treasurer::BaseController
  def index
    @transactions = Transaction.joins(member: :organization_memberships)
      .where(organization_memberships: { organization: current_organization })
      .includes(:member, :product)
      .order(created_at: :desc)
      .limit(100)

    @transactions = @transactions.where(member_id: params[:member_id]) if params[:member_id].present?
    @transactions = @transactions.sponsored if params[:sponsored] == "1"

    @member = current_organization.members.find(params[:member_id]) if params[:member_id].present?
  end

  def new
    @transaction = Transaction.new
    @members = current_organization.members.order(:display_name)
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
    @transaction = find_transaction
    @members = current_organization.members.order(:display_name)
  end

  def update
    @transaction = find_transaction
    if @transaction.update(transaction_params)
      redirect_to treasurer_transactions_path, notice: "Transaktion aktualisiert"
    else
      @members = current_organization.members.order(:display_name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    find_transaction.destroy
    redirect_to treasurer_transactions_path, notice: "Transaktion gelöscht"
  end

  private

  def find_transaction
    Transaction.joins(member: :organization_memberships)
      .where(organization_memberships: { organization: current_organization })
      .find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(:member_id, :amount_cents, :kind, :note)
  end
end
