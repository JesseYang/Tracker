class Log
  include Mongoid::Document
  include Mongoid::Timestamps
  include HTTParty

  base_uri 'http://www.minigps.net'
  format :json

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
      if bs.blank?
        bs = self.create_bs_by_api(bs_info)
        next if bs.blank?
      end
      bs_ary << {
        lat: bs.lat.to_f,
        lng: bs.lng.to_f,
        lat_mars: bs.lat_offset.to_f,
        lng_mars: bs.lng_offset.to_f,
        ss: bs_info["ss"].to_f}
    end
    lat_mars_sum = lng_mars_sum = lat_sum = lng_sum = ss_sum = 0 
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

  def create_bs_by_api(bs_info)
    result = self.class.get("/l.do",
      {:query => {
        :c => bs_info["mcc"],
        :n => bs_info["mnc"],
        :a => bs_info["lac"],
        :e => bs_info["cellid"]},
        :headers => { 'Content-Type' => 'application/json;charset=UTF-8' } })
    puts result.parsed_response
    # create a new bs if the bs can be found
    # return the new bs instance
  end
end
