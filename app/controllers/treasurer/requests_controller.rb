class Treasurer::RequestsController < ApplicationController
  def index
    @requests = Request.includes(:member).order(created_at: :desc)
  end

  def show
    @request = Request.find(params[:id])
  end

  def approve
    @request = Request.find(params[:id])

    kind = @request.expense? ? :expense_reimbursement : :deposit

    Transaction.create!(
      member: @request.member,
      kind: kind,
      amount_cents: @request.amount_cents,
      note: "Erstattung: #{@request.description}"
    )

    @request.update!(status: :approved)
    MemberMailer.request_approved(@request).deliver_later
    redirect_to treasurer_requests_path, notice: "Antrag genehmigt!"
  end

  def reject
    @request = Request.find(params[:id])
    @request.update!(
      status: :rejected,
      note: params[:note]
    )
    MemberMailer.request_rejected(@request).deliver_later
    redirect_to treasurer_requests_path, notice: "Antrag abgelehnt!"
  end
end
