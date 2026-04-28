class ApplicationController < ActionController::Base
  include Pundit::Authorization
  before_action :authenticate_member!
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  def after_sign_in_path_for(resource)
    if resource.treasurer?
      treasurer_root_path
    elsif resource.inventory_manager?
      inventory_root_path
    else
      kiosk_root_path
    end
  end

  def after_sign_out_path(resource_or_scope)
    root_path
  end

  def stored_location_for(resource)
    nil
  end

  def after_sign_out_path_for(resource)
    new_member_session_path
  end

  def current_member
    @current_member ||= warden.authenticate(scope: :member)
  end
  helper_method :current_member

end
