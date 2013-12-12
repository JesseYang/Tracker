class LogCorrectWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :queue => "tracker_#{Rails.env}".to_sym

  def perform(log_id)
    log = Log.find(log_id)
    lat_offset, lng_offset = *Offset.correct(log.lat.to_f, log.lng.to_f)
    log.update_attributes({ lat_offset: lat_offset, lng_offset: lng_offset })
  end
end
