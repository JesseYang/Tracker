class LogBsWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :queue => "tracker_#{Rails.env}".to_sym

  def perform(log_id)
    log = Log.find(log_id)
    log.cal_bs_based_loc
  end
end
