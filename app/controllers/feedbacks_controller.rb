# encoding: utf-8
class FeedbacksController < ApplicationController
  before_filter :require_admin, :only => [:index, :show]

  def index
    @feedbacks = Feedback.all.desc(:created_at)
  end

  def new
    session[:return_to] ||= request.referer
    @feedback = Feedback.new
  end

  def create
    feedback = Feedback.create(params[:feedback])
    flash[:notice] = "反馈已成功提交，谢谢您的关注！"
    redirect_to session.delete(:return_to)
  end

  def show
    @feedback = Feedback.find(params[:id])
  end
end
