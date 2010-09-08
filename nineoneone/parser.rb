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
        OpenStruct.new(:datetime =>  Time.parse(cells[0].content.strip),
                       :incident_num => cells[1].content.strip,
                       :level => cells[2].content.strip,
                       :units => cells[3].content.strip.split(" "),
                       :location => cells[4].content.strip,
                       :incident_type => cells[5].content.strip)
      end
    end

    def top(limit)
      sorted = recent_rows_by_location.sort_by{|location, rows| rows.length}.reverse
      top = sorted[0,limit]
      top.map{|location, rows| [location, rows]}
    end

    def at_least(limit)
      at_least = recent_rows_by_location.select do |location, rows|
        rows.sum(&:units).uniq.length >= limit
      end
      at_least.map{|location, rows| [location, rows]}
    end

  private

    def recent_rows_by_location
      oldest_datetime = Time.now - 14400 # 4 hours
      recent_rows = @rows.select{|row| row.datetime > oldest_datetime}
      locations = recent_rows.map(&:location).uniq

      locations.map do |location|
        [location, recent_rows.select{|row| row.location == location}]
      end
    end
  end
end