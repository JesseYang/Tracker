# encoding: utf-8
class ChangeLogsController < ApplicationController

  def index
    @change_logs = ChangeLog.all.desc(:created_at)
  end

  def create
    redirect_to action: :index and return if current_user.try(:admin) != true
    change_log = ChangeLog.create(params[:change_log])
    flash[:notice] = "创建更新日志成功"
    redirect_to action: :index and return
  end

  def show
    @change_log = ChangeLog.find(params[:id])
  end

  def destroy
    redirect_to action: :index and return if current_user.try(:admin) != true
    @change_log = ChangeLog.find(params[:id])
    @change_log.destroy
    redirect_to action: :index and return
  end
end
