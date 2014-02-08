# encoding: utf-8
require 'string'
class FencesController < ApplicationController

  def index
    @device = Device.find_by_id(params[:device_id])
    @fences = @device.fences.desc(:generated_at)
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
    @fence = Fence.find(params[:id])
  end
end
