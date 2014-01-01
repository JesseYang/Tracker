class ChangeLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title, :type => String
  field :content, :type => String
  field :generated_at, :type => Integer

end
