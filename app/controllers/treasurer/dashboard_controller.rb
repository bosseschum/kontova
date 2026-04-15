class Treasurer::DashboardController < Treasurer::BaseController
  def index
    @members = Member.order(:display_name)
  end
end
