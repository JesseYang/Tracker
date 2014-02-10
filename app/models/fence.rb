# encoding: utf-8
require 'array'
require 'math'
class Fence
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String, default: "未命名电子围栏"
  field :points, type: Array, default: []
  field :enabled, type: Boolean, default: true

  LONGITUDE_BASE = 0.005
  LATITUDE_BASE = 0.002

  belongs_to :device

  def points_center
    latitude_ary = self.points.map { |e| e[0] }
    longitude_ary = self.points.map { |e| e[1] }
    return [latitude_ary.mean, longitude_ary.mean]
  end

  def points_zoom
    latitude_ary = self.points.map { |e| e[0] }
    longitude_ary = self.points.map { |e| e[1] }
    latitude_diff = latitude_ary.max - latitude_ary.min
    longitude_diff = longitude_ary.max - longitude_ary.min
    zoom = []
    zoom << (longitude_diff == 0 ? 18 : (18 - Math.my_log(2, longitude_diff / LONGITUDE_BASE)).floor)
    zoom << (latitude_diff == 0 ? 18 : (18 - Math.my_log(2, latitude_diff / LATITUDE_BASE)).floor)
    zoom << 18
    @zoom = zoom.min
  end
end
