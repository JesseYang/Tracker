# encoding: utf-8
class DevicesController < ApplicationController
  before_filter :require_sign_in

  def index
    @devices = current_user.devices
  end

  def show_map
    @demo = params[:demo].to_s == "true"
    @device = Device.find_by_id(params[:id])
    if @demo
      demo_logs = Log.where(demo: true).asc(:generated_at)
      if params[:log_index].nil?
        @logs = demo_logs.limit(1)
      else
        @logs = demo_logs.length > params[:log_index].to_i ? demo_logs.limit(params[:log_index].to_i) : demo_logs
      end
    else
      @logs = @device.eff_logs.asc(:created_at)
      if params[:start_time].present?
        start_time = Time.mktime(*params[:start_time].scan(/(.*)\/(.*)\/(.*)\s*-\s*(.*):(.*)/)[0]).to_i
        @logs = @logs.where(:generated_at.gt => start_time)
      end
      if params[:end_time].present?
        end_time = Time.mktime(*params[:end_time].scan(/(.*)\/(.*)\/(.*)\s*-\s*(.*):(.*)/)[0]).to_i
        @logs = @logs.where(:generated_at.lt => end_time)
      end
      @logs = @logs.select { |e| e.lat_offset.present? && e.lng_offset.present? }
    end
    if @logs.blank?
      @center = [39.916527,116.397128]
      @zoom = 8
    else
      @start = [@logs[0].lat_offset, @logs[0].lng_offset]
      @end = [@logs[-1].lat_offset, @logs[-1].lng_offset]
      @center = @demo ? Log.demo_log_center(@logs) : @device.log_center
      @zoom = @demo ? Log.demo_log_zoom(@logs) : @device.log_zoom
    end
    @devices = current_user.devices
    @start_str = params[:start_time]
    @end_str = params[:end_time]

    respond_to do |format|
      format.html # show_map.haml
      format.json do
        render json: { logs: @logs }
      end
    end
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
