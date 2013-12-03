# encoding: utf-8
class DevicesController < ApplicationController
  before_filter :require_sign_in

  def index
    @devices = current_user.devices
  end

  def show_map
    @device = Device.find_by_id(params[:id])
    @logs = @device.logs.asc(:created_at)
    @logs = @logs.select { |e| e.lat_mars.present? && e.lng_mars.present? }
    if @logs.blank?
      @center = [39.916527,116.397128]
      @zoom = 8
    else
      @center = @device.log_center
      @start = [@logs[0].lat_mars, @logs[0].lng_mars]
      @end = [@logs[-1].lat_mars, @logs[-1].lng_mars]
      @zoom = @device.log_zoom
    end
    @devices = current_user.devices
  end

  def new
    @device = Device.new
    @current_user = current_user
  end

  def create
    @device = Device.create(params[:device])
    flash[:notice] = "创建新设备成功"
    redirect_to action: 'index' and return
  end

  def destroy
    @device = current_user.devices.find_by_id(params[:id])
    @device.destroy
    redirect_to :action => :index and return
  end
end
