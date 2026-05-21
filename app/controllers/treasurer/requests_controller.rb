class Treasurer::RequestsController < Treasurer::BaseController
  def index
    @requests = Request.joins(:member)
      .where(members: { organization: current_organization })
      .includes(:member)
      .order(created_at: :desc)
  end

  def show
    @request = Request.joins(:member)
      .where(members: { organization: current_organization })
      .find(params[:id])
  end

  def approve
    @request = Request.joins(:member)
      .where(members: { organization: current_organization })
      .find(params[:id])

    kind = @request.expense? ? :expense_reimbursement : :deposit

    Transaction.create!(
      member:       @request.member,
      amount_cents: @request.amount_cents,
      kind:         kind,
      note:         "Erstattung: #{@request.description}"
    )

    @request.update!(status: :approved)
    MemberMailer.request_approved(@request).deliver_later

    redirect_to treasurer_requests_path, notice: "Antrag genehmigt"
  end

  def reject
    @request = Request.joins(:member)
      .where(members: { organization: current_organization })
      .find(params[:id])

    @request.update!(status: :rejected, note: params[:note])
    MemberMailer.request_rejected(@request).deliver_later

    redirect_to treasurer_requests_path, notice: "Antrag abgelehnt"
  end
end
