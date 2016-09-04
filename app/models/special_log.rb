#encoding: utf-8
class SpecialLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :folder, :type => String
  field :filename, :type => String
  field :data, :type => String

end
