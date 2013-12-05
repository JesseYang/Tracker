class Log
  include Mongoid::Document
  include Mongoid::Timestamps

  field :lat, :type => Float
  field :lng, :type => Float
  field :lat_mars, :type => Float
  field :lng_mars, :type => Float
  # each element of bs_ss corresponds to one bs, and is a hash, the keys of which are:
  #   mcc:
  #   mnc:
  #   lac:
  #   cellid:
  #   ss:
  # the former four can identify at most one bs
  field :bs_ss, :type => Array
  field :generated_at, :type => Integer

  belongs_to :device

  def cal_bs_based_loc
    return if bs_ss.blank?
    bs_ary = []
    bs_ss.each do |bs_info|
      bs = BaseStation.where(mcc: bs_info["mcc"], mnc: bs_info["mnc"], lac: bs_info["lac"], cellid: bs_info["cellid"]).first
      next if bs.blank?
      bs_ary << {
        lat: bs.lat.to_f,
        lng: bs.lng.to_f,
        lat_mars: bs.lat_offset.to_f,
        lng_mars: bs.lng_offset.to_f,
        ss: bs_info["ss"].to_f}
    end
    lat_mars_sum = 0 
    lng_mars_sum = 0
    lat_sum = 0
    lng_sum = 0
    ss_sum = 0
    bs_ary.each do |e|
      lat_mars_sum += e[:lat_mars] * e[:ss]
      lng_mars_sum += e[:lng_mars] * e[:ss]
      lat_sum += e[:lat] * e[:ss]
      lng_sum += e[:lng] * e[:ss]
      ss_sum += e[:ss]
    end
    self.lat_mars = (lat_mars_sum / ss_sum).round(6)
    self.lng_mars = (lng_mars_sum / ss_sum).round(6)
    self.lat = (lat_sum / ss_sum).round(6)
    self.lng = (lng_sum / ss_sum).round(6)
    self.save
  end
end
