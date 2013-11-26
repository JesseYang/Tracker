class LogCorrectWorker
  include Sidekiq::Worker

  def perform(log_id, latitude, longitude)
  	log = Log.find(log_id)
    lat_mars, lng_mars = *Offset.correct(latitude.to_f, longitude.to_f)
    log.update_attributes({ lat_mars: lat_mars, lng_mars: lng_mars })
  end
end
