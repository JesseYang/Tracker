class ImportWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 10, :queue => "tracker_#{Rails.env}".to_sym

  def perform(type, file_number)
    if type == "xml"
      BaseStation.import_xml(file_number)
    elsif type == "csv"
      BaseStation.import_csv(file_number)
    end
  end
end
