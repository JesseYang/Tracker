require 'array'
require 'math'
class Device
  include Mongoid::Document

  field :name
  field :imei

  LONGITUDE_BASE = 0.005
  LATITUDE_BASE = 0.002

  belongs_to :user
  has_many :logs

  def self.find_by_id(device_id)
    return self.where(id: device_id).first
  end

  def eff_logs
    return self.logs.where(:lat.ne => nil)
  end

  def self.find_by_imei(imei)
    return self.where(imei: imei).first
  end

  def log_center
    latitude_ary = self.eff_logs.map { |e| e.lat_offset }
    longitude_ary = self.eff_logs.map { |e| e.lng_offset }
    return [latitude_ary.mean, longitude_ary.mean]
  end

  def log_zoom
    latitude_ary = self.eff_logs.map { |e| e.lat_offset }
    longitude_ary = self.eff_logs.map { |e| e.lng_offset }
    latitude_diff = latitude_ary.max - latitude_ary.min
    longitude_diff = longitude_ary.max - longitude_ary.min
    zoom = []
    zoom << (longitude_diff == 0 ? 18 : (18 - Math.my_log(2, longitude_diff / LONGITUDE_BASE)).floor)
    zoom << (latitude_diff == 0 ? 18 : (18 - Math.my_log(2, latitude_diff / LATITUDE_BASE)).floor)
    zoom << 18
    @zoom = zoom.min
  end
end
