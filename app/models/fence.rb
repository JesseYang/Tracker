# encoding: utf-8
require 'array'
require 'math'
class Fence
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String, default: "未命名电子围栏"
  field :path, type: Array, default: []
  field :enabled, type: Boolean, default: true

  belongs_to :device

end
