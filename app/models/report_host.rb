class ReportHost

  include HTTParty
  base_uri 'http://deploy.oopsdata.com'
  format :json

  def initialize
  end

  def self.report_host
    result = self.post("/hosts.json", { :body => {}.to_json, :headers => { 'Content-Type' => 'application/json' } })
    puts result.inspect
  end
end
