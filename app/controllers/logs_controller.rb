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
 
  def device_create_bs
    device = Device.where(imei: params[:imei]).first
    render :json => {
      :success => false,
      :value => "Device Not Found"
    } and return if device.nil?
    bs_ary = params[:bs_ss].split('&')
    bs_ss = []
    bs_ary.each do |bs|
      temp = bs.split(',')
      next if temp[4] == 0
      bs_ss << {mcc: temp[0].to_i, mnc: temp[1].to_i, lac: temp[2].hex2int, cellid: temp[3].hex2int, ss: temp[4].to_f}
    end
    log = Log.create(bs_ss: bs_ss,
      generated_at: params[:generated_at].present? ? params[:generated_at].to_i : Time.now.to_i)
    LogBsWorker.perform_async(log.id)
    device.logs << log
    render :json => {
      :success => true,
      :value => ""
    } and return
  end

  def bs_detail
    log = Log.find(params[:id])
    render :partial => 'logs/bs_detail', :locals => { bs_ss: log.bs_ss } and return
  end
end
