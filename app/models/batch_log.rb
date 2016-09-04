#encoding: utf-8
class BatchLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :data_ary, :type => Array, default: []
  field :data, :type => String
  field :data_id, :type => String

  belongs_to :device

  def self.create_new(device, data_id)
    batch_log = BatchLog.create(device_id: device.id, data_id: data_id)
    batch_log
  end

  def push_data(data_order, data)
    index = ("a".."l").to_a.index(data_order)
    self.data_ary[index] = data
    finish = true
    0.upto(11) do |e|
      if self.data_ary[e].blank?
        finish = false
        break
      end
    end
    if finish
      self.data = self.data_ary.join
      self.save
      true
    else
      false
    end
  end
end
