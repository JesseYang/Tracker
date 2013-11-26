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
    device = Device.find_by_imei(params[:imei])
    LogCreationWorker.perform_async(device.id, params[:latitude], params[:longitude])
    render json: true and return
  end
end
