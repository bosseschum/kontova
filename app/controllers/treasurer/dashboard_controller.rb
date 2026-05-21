class Treasurer::DashboardController < Treasurer::BaseController
  def index
    @members = current_organization.members.order(:display_name)
  end
end
