require 'array'
require 'math'
class BaseStation
  include Mongoid::Document

  field :cell_id, :type => Integer
  field :v1, :type => Integer
  field :v2, :type => Integer
  field :v3, :type => Integer
  field :v4, :type => Integer
  field :lat, :type => Float
  field :lng, :type => Float
  field :lat_offset, :type => Float
  field :lng_offset, :type => Float
  field :v9, :type => Integer
  field :description, :type => String

  def self.import_xml(file_number)
    1.upto(file_number).each do |num|
      xml = Nokogiri::XML(File.read("lib/d#{num.to_s}.xml"))
      xml.xpath('//cellsdata').each do |cell_data|
        cell_id = cell_data.xpath(".//idcells")[0].text.to_s
        lat = cell_data.xpath("lat")[0].text.to_f
        lng = cell_data.xpath("lon")[0].text.to_f
        lat_offset = cell_data.xpath("offsetlat")[0].text.to_f
        lng_offset = cell_data.xpath("offsetlon")[0].text.to_f
        next if BaseStation.where(cell_id: cell_id).present?
        BaseStation.create(cell_id: cell_id, lat: lat, lng: lng, lat_offset: lat_offset, lng_offset: lng_offset)
      end
    end
  end

  def self.import_csv(file_number)
    1.upto(file_number).each do |num|
      content = File.read("lib/d#{num}.csv")
      CSV.parse(content) do |row|
        cell_id = row[0].to_i
        bs = BaseStation.where(cell_id: cell_id)
        next if bs.nil?
        bs.description = row[10]
        bs.v1 = row[1]
        bs.v2 = row[2]
        bs.v3 = row[3]
        bs.v4 = row[4]
        bs.v9 = row[9]
        bs.save
      end
    end
  end
end
