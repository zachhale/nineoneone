require 'nokogiri'
require 'open-uri'
require 'ostruct'

module NineOneOne
  class Parser
    attr_reader :rows
    
    def initialize
      doc = Nokogiri::HTML(open("http://www2.seattle.gov/fire/realTime911/getRecsForDatePub.asp?action=Today&incDate=&rad1=des"))
            
      @rows = doc.xpath('/html/body/table[1]/tr[3]/td/table/tr/td/table/tr').map do |row|
        cells = row.xpath('td')
        OpenStruct.new(:datetime => cells[0].content.strip,
                       :incident_num => cells[1].content.strip,
                       :level => cells[2].content.strip,
                       :units => cells[3].content.strip.split(" "),
                       :location => cells[4].content.strip,
                       :incident_type => cells[5].content.strip)
      end
    end
    
    def top(limit)
      sorted = rows_by_location.sort_by{|location, rows| rows.length}.reverse
      top = sorted[0,limit]
      top.map{|location, rows| [location, rows]}
    end
    
    def at_least(limit)
      at_least = rows_by_location.select{|location, rows| rows.sum(&:units).length >= limit}
      at_least.map{|location, rows| [location, rows]}
    end
    
  private
  
    def rows_by_location
      locations = @rows.map(&:location).uniq
      with_rows = locations.map do |location|
        [location, @rows.select{|row| row.location == location}]
      end
    end
  end
end