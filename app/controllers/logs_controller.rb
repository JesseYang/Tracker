# encoding: utf-8
require 'string'
class LogsController < ApplicationController

  def index
    @device = Device.find_by_id(params[:device_id])
    @logs = @device.logs.desc(:generated_at)
    if params[:start_time].present?
      start_time = Time.mktime(*params[:start_time].scan(/(.*)\/(.*)\/(.*)\s*-\s*(.*):(.*)/)[0]).to_i
      @logs = @logs.where(:generated_at.gt => start_time)
    end
    if params[:end_time].present?
      end_time = Time.mktime(*params[:end_time].scan(/(.*)\/(.*)\/(.*)\s*-\s*(.*):(.*)/)[0]).to_i
      @logs = @logs.where(:generated_at.lt => end_time)
    end
    @logs = auto_paginate @logs
    @start_str = params[:start_time]
    @end_str = params[:end_time]
  end

  def new
    @log = Log.new
    @device = Device.find_by_id(params[:device_id])
  end

  def create
    log = Log.create(params[:log])
    log.lat_offset = log.lat
    log.lng_offset = log.lng
    log.generated_at = params[:generated_at].present? ? params[:generated_at].to_i : Time.now.to_i
    log.save
    LogCorrectWorker.perform_async(log.id)
    redirect_to :action => :index, :device_id => params[:log]["device_id"] and return
  end

  def clear
    @device = Device.find_by_id(params[:device_id])
    @device.logs.destroy_all
    redirect_to :action => :index, :device_id => params[:device_id] and return
  end

  def device_create_gps
    device = Device.where(imei: params[:imei]).first
    render :json => {
      :success => false,
      :value => "Device Not Found"
    } and return if device.nil?
    batch_log = device.batch_logs.where(:data_id => params[:data_id]).first
    batch_log = BatchLog.create_new(device, params[:data_id]) if batch_log.blank?
    ret = batch_log.push_data(params[:order], params[:data])
    if ret
      # data collection for this batch log has finished
    else
      # data is not complete
    end
    render text: 'ok' and return
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
      lat_offset: params[:lat].to_f,
      lng_offset: params[:lng].to_f,
      generated_at: params[:generated_at].present? ? params[:generated_at].to_i : Time.now.to_i)
    device.logs << log
    LogCorrectWorker.perform_async(log.id)
    render :json => {
      :success => true,
      :value => ""
    } and return
  end

  def new_special_log
  end

  def create_special_log
    sl = SpecialLog.create(folder: params[:imei],
      filename: "AT#{Time.now.strftime('%Y%m%d%H%M%S')}",
      data: params[:data])
    flash[:notice] = "创建成功"
    redirect_to action: :list_special_logs and return
  end

  def delete_special_log
    sp = SpecialLog.find(params[:id])
    sp.destroy
    flash[:notice] = "删除成功"
    redirect_to action: :list_special_logs and return
  end

  def list_special_logs
    @special_logs = SpecialLog.all
  end
 
  def device_create_bs
    if params[:type] == "A" || params[:type] == "a"
      sl = SpecialLog.create(folder: params[:imei],
        filename: "AT#{Time.now.strftime('%Y%m%d%H%M%S')}",
        data: params[:data])
      render :json => {
        :success => true,
        :value => ""
      } and return
    end

    device = Device.where(imei: params[:imei]).first
    render :json => {
      :success => false,
      :value => "Device Not Found"
    } and return if device.nil?
    bs_ss = BaseStation.parse_bs_data(params[:data], params[:type])
    log = Log.create(bs_ss: bs_ss,
      generated_at: params[:generated_at].present? ? params[:generated_at].to_i : Time.now.to_i)
    LogBsWorker.perform_async(log.id)
    device.logs << log
    render :json => {
      :success => true,
      :value => ""
    } and return
  end

  # render partial for a json request
  def bs_detail
    log = Log.find(params[:id])
    render :partial => 'logs/bs_detail', :locals => { bs_ss: log.bs_ss } and return
  end
end
