class LogCorrectWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 10, :queue => "tracker_#{Rails.env}".to_sym

  def perform(log_id)
    log = Log.find(log_id)
    lat_mars, lng_mars = *Offset.correct(log.lat.to_f, log.lng.to_f)
    log.update_attributes({ lat_mars: lat_mars, lng_mars: lng_mars })
  end
end
