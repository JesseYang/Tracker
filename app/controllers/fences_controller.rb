# encoding: utf-8
require 'string'
class FencesController < ApplicationController

  def index
    @device = Device.find_by_id(params[:device_id])
    @fences = @device.fences.desc(:generated_at)
  end

  def create
    fence = Fence.create(params[:fence])
    device = Device.find(params[:device_id])
    device.fences << fence
    respond_to do |format|
      format.html
      format.json do
        render json: { success: true }
      end
    end
  end

  def new
    @device = Device.find_by_id(params[:device_id])
    @logs = @device.eff_logs.asc(:created_at)
    @logs = @logs.select { |e| e.lat_offset.present? && e.lng_offset.present? }
    if @logs.blank?
      @center = [39.916527,116.397128]
      @zoom = 8
    else
      @center = @device.log_center
      @zoom = @device.log_zoom
    end
  end

  def enable
    @fence = Fence.find(params[:id])
    @fence.enabled = params[:enabled].to_s == "true"
    @fence.save
    respond_to do |format|
      format.html
      format.json do
        render json: { success: true }
      end
    end
  end

  def show
    @device = Device.find(params[:device_id])
    @fence = Fence.find(params[:id])
    @points = @fence.points
    if @points.blank?
      @center = [39.916527,116.397128]
      @zoom = 8
    else
      @center = @fence.points_center
      @zoom = @fence.points_zoom
    end
  end

  def update
    device = Device.find(params[:device_id])
    fence = Fence.find(params[:id])
    fence.update_attributes(params[:fence])
    respond_to do |format|
      format.html
      format.json do
        render json: { success: true }
      end
    end
  end
end
