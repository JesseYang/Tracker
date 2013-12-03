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
    return if bs_array.blank?
    bs_ary = []
    bs_ss.each do |bs_info|
      bs = BaseStation.where(mcc: bs_info[:mcc], mnc: bs_info[:mnc], lac: bs_info[:lac], cellid: bs_info[:cellid])
      next if bs.blank?
      bs_ary << {lat: bs.lat_offset.to_f, lng: bs.lng_offset.to_f, ss: bs_info[:ss].to_f}
    end
    lat_mars_sum = 0 
    lng_mars_sum = 0
    ss_sum = 0
    bs_ary.each do |e|
      lat_mars_sum += e[:lat] * e[:ss]
      lng_mars_sum += e[:lng] * e[:ss]
      ss_sum += e[:ss]
    end
    self.lat_mars = lat_mars_sum / ss_sum
    self.lng_mars = lng_mars_sum / ss_sum
    self.save
  end
end
