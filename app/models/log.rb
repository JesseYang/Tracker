#encoding: utf-8
class Log
  include Mongoid::Document
  include Mongoid::Timestamps

  field :lat, :type => Float
  field :lng, :type => Float
  field :lat_offset, :type => Float
  field :lng_offset, :type => Float
  # each element of bs_ss corresponds to one bs, and is a hash, the keys of which are:
  #   mcc:
  #   mnc:
  #   lac:
  #   cellid:
  #   ss:
  # the former four can identify at most one bs
  field :bs_ss, :type => Array
  field :generated_at, :type => Integer
  field :demo, :type => Boolean, default: false

  belongs_to :device

  def cal_bs_based_loc
    return if bs_ss.blank?
    bs_ary = []
    bs_ss.each do |bs_info|
      bs = BaseStation.find_bs_by_info(bs_info)
      next if bs.nil?
      bs_ary << {
        lat: bs.lat_std,
        lng: bs.lng_std,
        lat_offset: bs.lat_offset,
        lng_offset: bs.lng_offset,
        ss: bs_info["ss"].to_f}
    end
    return if bs_ary.blank?
    lat_offset_sum = lng_offset_sum = lat_sum = lng_sum = ss_sum = 0 
    bs_ary.each do |e|
      lat_offset_sum += e[:lat_offset] * e[:ss]
      lng_offset_sum += e[:lng_offset] * e[:ss]
      lat_sum += e[:lat] * e[:ss]
      lng_sum += e[:lng] * e[:ss]
      ss_sum += e[:ss]
    end
    self.lat_offset = (lat_offset_sum / ss_sum).round(6)
    self.lng_offset = (lng_offset_sum / ss_sum).round(6)
    self.lat = (lat_sum / ss_sum).round(6)
    self.lng = (lng_sum / ss_sum).round(6)
    self.save
  end


  def self.create_demo_logs
    Log.where(demo: true).destroy_all
    lat_lng_array = [
      [40.016802,116.368924],
      [40.017648,116.368892],
      [40.017689,116.370308],
      [40.017681,116.371413],
      [40.017714,116.372872],
      [40.017673,116.374492],
      [40.016703,116.374578],
      [40.016038,116.374642]
    ]
    time = Time.now.to_i
    lat_lng_array.each do |lat_lng|
      Log.create(lat: lat_lng[0],
        lng: lat_lng[1],
        lat_offset: lat_lng[0],
        lng_offset: lat_lng[1],
        demo: true,
        generated_at: time)
      time += 1
    end
  end

  def self.demo_log_center(logs)
    latitude_ary = logs.map { |e| e.lat_offset }
    longitude_ary = logs.map { |e| e.lng_offset }
    return [latitude_ary.mean, longitude_ary.mean]
  end

  def self.demo_log_zoom(logs)
    latitude_ary = logs.map { |e| e.lat_offset }
    longitude_ary = logs.map { |e| e.lng_offset }
    latitude_diff = latitude_ary.max - latitude_ary.min
    longitude_diff = longitude_ary.max - longitude_ary.min
    zoom = []
    zoom << (longitude_diff == 0 ? 18 : (18 - Math.my_log(2, longitude_diff / Device::LONGITUDE_BASE)).floor)
    zoom << (latitude_diff == 0 ? 18 : (18 - Math.my_log(2, latitude_diff / Device::LATITUDE_BASE)).floor)
    @zoom = zoom.min
  end

  def bs_info
    return "无" if self.bs_ss.blank?
    return "非境内基站" if bs_ss[0]["mcc"].to_i != 460
    bs_info = "中国"
    case bs_ss[0]["mnc"].to_i
    when 0, 2
      bs_info += "移动"
    when 1
      bs_info += "联通"
    when 3
      bs_info += "电信"
    end
    bs_info += "; 大区号: #{bs_ss[0]["lac"]}"
    # bs_info += "; 小区id: #{bs_ss[0]["cellid"]}"
    bs_info += "..."
    return bs_info
  end

  def has_bs_info?
    self.bs_ss.present? && self.bs_ss[0]["mcc"].to_i == 460
  end
end
