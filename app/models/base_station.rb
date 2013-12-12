require 'array'
require 'math'
class BaseStation
  include Mongoid::Document
  include HTTParty

  base_uri 'http://www.minigps.net'
  format :json

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
  field :lat_api, :type => Float
  field :lng_api, :type => Float
  field :radius, :type => Integer
  field :description, :type => String

  validates :uniq_id, uniqueness: true

  index({ uniq_id: 1 }, { background: true })
  index({ mcc: 1, mnc: 1, lac: 1, cellid: 1 })

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
      CSV.parse(content.encode('utf-8', 'gbk')) do |row|
        tot_number += 1
        puts tot_number if tot_number%1000 == 0
        uniq_id = row[0].to_i
        bs = BaseStation.where(uniq_id: uniq_id).first
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

  def self.find_bs_by_info(bs_info)
    result = self.get("/l.do",
      {:query => {
        :c => bs_info["mcc"],
        :n => bs_info["mnc"],
        :a => bs_info["lac"],
        :e => bs_info["cellid"],
        :mt => 0},
        :headers => { 'Content-Type' => 'application/json;charset=UTF-8' } })
    puts result.parsed_response
    result = result.parsed_response
    return nil if result["cause"] != "OK"
    bs = BaseStation.where(mcc: bs_info["mcc"], mnc: bs_info["mnc"], lac: bs_info["lac"], cellid: bs_info["cellid"]).first
    bs = BaseStation.create(mcc: bs_info["mcc"], mnc: bs_info["mnc"], lac: bs_info["lac"], cellid: bs_info["cellid"]) if bs.nil?
    bs.lat_api = result["lat"].to_f
    bs.lng_api = result["lng"].to_f
    bs.lat_offset, bs.lng_offset = *Offset.correct(bs.lat_api, log.lng_api)
    bs.save
    return bs
  end

  def lat_std
    return self.lat_api || self.lat
  end

  def lng_std
    return self.lng_api || self.lng
  end
end
