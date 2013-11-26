class LogCreationWorker
  include Sidekiq::Worker

  def perform(device_id, latitude, longitude)
    latitude, longitude = *Offset.correct(latitude.to_f, longitude.to_f)
    log = Log.create(
      generated_at: Time.now.to_i,
      latitude: latitude,
      longitude: longitude
      )
  end
end
