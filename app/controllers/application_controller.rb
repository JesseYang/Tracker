class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :user_signed_in?, :user_admin?, :current_user

  def require_sign_in
    redirect_to :root if current_user.blank?
  end

  def require_admin
    redirect_to :root if current_user.try(:admin) != true
  end

  def after_sign_in_path_for(resource)
  	devices_path
  end

  def user_sign_in?
  	current_user.present?
  end

  def user_admin?
    current_user.try(:admin)
  end

  def render_404
    raise ActionController::RoutingError.new('Not Found')
  end

  def render_500
    raise '500 exception'
  end
end
