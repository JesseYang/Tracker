class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :user_signed_in?, :current_user

  def require_sign_in
    redirect_to :root if current_user.blank?
  end

  def after_sign_in_path_for(resource)
  	devices_path
  end

  def user_sign_in?
  	current_user.present?
  end
end
