class LogsController < ApplicationController

  def index
    @device = Device.find_by_id(params[:device_id])
    @logs = @device.logs
  end

  def new
    @log = Log.new
    @device = Device.find_by_id(params[:device_id])
  end

  def create
    log = Log.create(params[:log])
    log.lat_mars = log.lat
    log.lng_mars = log.lng
    log.generated_at = Time.now.to_i
    log.save
    LogCorrectWorker.perform_async(log.id)
    redirect_to :action => :index, :device_id => params[:log]["device_id"] and return
  end

  def device_create
    device = Device.where(imei: params[:imei]).first
    render :json => {
      :success => false,
      :value => "Device Not Found"
    } and return if device.nil?
    log = Log.create(
      lat: params[:lat].to_f,
      lng: params[:lng].to_f,
      lat_mars: params[:lat].to_f,
      lng_mars: params[:lng].to_f,
      generated_at: Time.now.to_i)
    device.logs << log
    LogCorrectWorker.perform_async(log.id)
    render :json => {
      :success => true,
      :value => ""
    } and return
  end
end
