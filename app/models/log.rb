class Log
  include Mongoid::Document
  include Mongoid::Timestamps

  field :latitude, :type => Float
  field :longitude, :type => Float
  field :generated_at, :type => Integer

  belongs_to :device

end
