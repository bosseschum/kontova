class ApplicationController < ActionController::Base
  include Pundit::Authorization
  before_action :authenticate_member!
  before_action :set_organization

  helper_method :current_organization

  def current_organization
    @current_organization
  end

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  def current_member
    @current_member ||= warden.authenticate(scope: :member)
  end
  helper_method :current_member

  private

  def set_organization
    return if current_member&.super_admin?

    subdomain = request.subdomain
    if subdomain.present? && subdomain != "www"
      @current_organization = Organization.active.find_by(subdomain: subdomain)
      unless @current_organization
        render plain: "Verein nicht gefunden", status: :not_found
      end
    else
      # Root domain
    end
  end

  def after_sign_in_path_for(resource)
    if resource.super_admin?
      super_admin_root_path
    elsif resource.treasurer?
      treasurer_root_path
    elsif resource.inventory_manager?
      inventory_root_path
    else
      member_area_root_path
    end
  end

  def after_sign_out_path_for(resource)
    new_member_session_path
  end

  def stored_location_for(resource)
    nil
  end

  def after_sign_out_path(resource_or_scope)
    root_path
  end
end
