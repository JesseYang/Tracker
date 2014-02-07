class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :user_signed_in?, :user_admin?, :current_user

  def require_sign_in
    respond_to do |format|
      format.html do
        redirect_to new_user_session_path and return if current_user.blank?
      end
      format.json do
        if current_user.blank?
          render json: { success: false, reason: "require sign in" } and return
        end
      end
    end
  end

  def require_admin
    redirect_to new_user_session_path if current_user.try(:admin) != true
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

  def page
    params[:page].to_i == 0 ? 1 : params[:page].to_i
  end

  def per_page
    params[:per_page].to_i == 0 ? 10 : params[:per_page].to_i
  end

  def auto_paginate(value, count = nil)
    retval = {}
    retval["current_page"] = page
    retval["per_page"] = per_page
    retval["previous_page"] = (page - 1 > 0 ? page - 1 : 1)
    # retval["previous_page"] = [page - 1, 1].max

    # 当没有block或者传入的是一个mongoid集合对象时就自动分页
    # TODO : 更优的判断是否mongoid对象?
    # instance_of?(Mongoid::Criteria) .by lcm
    # if block_given? 
    if value.methods.include? :page
      count ||= value.count
      value = value.page(retval["current_page"]).per(retval["per_page"])
    elsif value.is_a?(Array) && value.count > per_page
      count ||= value.count
      value = value.slice((page - 1) * per_page, per_page)
    end
      
    if block_given?
      retval["data"] = yield(value) 
    else
      retval["data"] = value
    end
    retval["total_page"] = ( (count || value.count )/ per_page.to_f ).ceil
    retval["total_page"] = retval["total_page"] == 0 ? 1 : retval["total_page"]
    retval["total_number"] = count || value.count
    retval["next_page"] = (page+1 <= retval["total_page"] ? page+1: retval["total_page"])
    retval
  end

end
