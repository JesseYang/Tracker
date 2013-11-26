class Log
  include Mongoid::Document
  include Mongoid::Timestamps

  field :lat, :type => Float
  field :lng, :type => Float
  field :lat_mars, :type => Float
  field :lng_mars, :type => Float
  field :generated_at, :type => Integer

  belongs_to :device

end
