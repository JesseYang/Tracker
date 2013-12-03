require 'array'
require 'math'
class BaseStation
  include Mongoid::Document

  field :uniq_id, :type => Integer
  # mcc, mnc, lac and cellid can identify at most only one BS
  # Mobile Country Code (mcc): 460 for China
  field :mcc, :type => Integer
  # Mobile Network Code (mcc): 0 for China Mobile; 1 for China Unicom, 2 for China Telecom
  field :mnc, :type => Integer
  # Location Area Code (lac)
  field :lac, :type => Integer
  # Cell Identity
  field :cellid, :type => Integer
  field :lat, :type => Float
  field :lng, :type => Float
  field :lat_offset, :type => Float
  field :lng_offset, :type => Float
  field :radius, :type => Integer
  field :description, :type => String

  index({uniq_id: 1})
  index({cellid: 1})

  def self.import_xml(file_number)
    tot_number = 0
    1.upto(file_number).each do |num|
      next if !File.exist?("lib/bs_db_xml/d#{num.to_s}.xml")
      xml = Nokogiri::XML(File.read("lib/bs_db_xml/d#{num.to_s}.xml"))
      xml.xpath('//cellsdata').each do |cell_data|
        tot_number += 1
        puts tot_number if tot_number%1000 == 0
        uniq_id = cell_data.xpath(".//idcells")[0].text.to_i
        # next if BaseStation.where(uniq_id: uniq_id).present?
        lat = cell_data.xpath("lat")[0].text.to_f
        lng = cell_data.xpath("lon")[0].text.to_f
        lat_offset = cell_data.xpath("offsetlat")[0].text.to_f
        lng_offset = cell_data.xpath("offsetlon")[0].text.to_f
        BaseStation.create(uniq_id: uniq_id, lat: lat, lng: lng, lat_offset: lat_offset, lng_offset: lng_offset)
      end
    end
  end

  def self.import_csv(file_number)
    tot_number = 0
    1.upto(file_number).each do |num|
      next if !File.exist?("lib/bs_db_csv/d#{num.to_s}.csv")
      content = File.read("lib/bs_db_csv/d#{num.to_s}.csv")
      CSV.parse(content) do |row|
        tot_number += 1
        puts tot_number if tot_number%1000 == 0
        uniq_id = row[0].to_i
        bs = BaseStation.where(uniq_id: uniq_id)
        next if bs.nil?
        bs.description = row[10]
        bs.mcc = row[1]
        bs.mnc = row[2]
        bs.lac = row[3]
        bs.cellid = row[4]
        bs.radius = row[9]
        bs.save
      end
    end
  end
end
