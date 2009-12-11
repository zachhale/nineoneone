require 'nokogiri'
require 'open-uri'
require 'ostruct'

module NineOneOne
  class Parser
    def initialize
      doc = Nokogiri::HTML(open("http://www2.seattle.gov/fire/realTime911/getRecsForDatePub.asp?action=Today&incDate=&rad1=des"))
            
      @rows = doc.xpath('/html/body/table[1]/tr[3]/td/table/tr/td/table/tr').map do |row|
        cells = row.xpath('td')
        OpenStruct.new(:datetime => cells[0].content,
                       :incident_num => cells[1].content,
                       :level => cells[2].content,
                       :units => cells[3].content,
                       :location => cells[4].content,
                       :type => cells[5].content)
      end
    end
    
    def top(limit)
      locations = @rows.map(&:location).uniq
      with_rows = locations.map do |location|
        [location, @rows.select{|row| row.location == location}]
      end
      sorted = with_rows.sort_by{|location, rows| rows.length}.reverse
      
      top = sorted#[0,limit]
      top.map{|location, rows| [location, rows.length]}
    end
  end
end