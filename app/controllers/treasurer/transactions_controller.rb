class Treasurer::TransactionsController < Treasurer::BaseController
  def index
    @transactions = Transaction.includes(:member, :product).order(created_at: :desc).limit(100)

    if params[:member_id].present?
      @transactions = @transactions.where(member_id: params[:member_id])
      @member = Member.find(params[:member_id])
    end
  end

  def new
    @transaction = Transaction.new
    @members = Member.order(:display_name)
  end

  def create
    @transaction = Transaction.new(transaction_params)
    # Einzahlungen/Erstattungen positiv, Beitrag negativ
    if @transaction.save
      redirect_to treasurer_transactions_path, notice: "Transaktion gebucht"
    else
      @members = Member.order(:display_name)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(
      :member_id, :amount_cents, :kind, :note
    )
  end
end
