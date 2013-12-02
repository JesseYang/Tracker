class Log
  include Mongoid::Document
  include Mongoid::Timestamps

  field :lat, :type => Float
  field :lng, :type => Float
  field :lat_mars, :type => Float
  field :lng_mars, :type => Float
  field :bs_ss, :type => Hash, default: {}
  field :generated_at, :type => Integer

  belongs_to :device

  def cal_bs_based_loc
    return if bs_array.blank?
    bs_ary = []
    bs_id_ary.each do |bs_id, ss|
      bs = BaseStation.where(uniq_id: bs_id)
      next if bs.blank?
      bs_ary << {lat: bs.lat_offset.to_f, lng: bs.lng_offset.to_f, ss: ss.to_f}
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
