require 'rubygems'
require 'redis'
require 'time'
require 'active_support'
require 'pony'

module NineOneOne
  class Runner
    @@interval = 60
    
    def initialize(recipients)
      @recipients = recipients
      @redis = Redis.new
    end
    
    def watch(meth, *args)
      loop do
        results = NineOneOne::Parser.new.send(meth, *args)
        
        base_key = "nineoneone:#{meth}"
        base_key << ":#{args.join(':')}" unless args.empty?
        
        # get the locations we've already notified about in the last 24 hours
        now = Time.now.to_i
        already_notified = @redis.zset_range_by_score(base_key, now - 24.hours.to_i, now)
        
        # throw out ones we've already flagged
        results.reject! { |location, rows| already_notified.include?(location.sub(' ','-')) }
        
        # notify for new ones
        results.each do |location, rows|
          puts "#{Time.now.strftime("%l:%M%P")}: #{location} # => #{rows.sum(&:units).length}"
          send_notification(rows)
          @redis.zset_add(base_key, Time.now.to_i, location.sub(' ','-'))
        end
        
        sleep @@interval
      end
    end
    
  private
  
    # 12:57am - E11 E37 M32 - 9422 24th Av SW - Medic Response, 7 per Rule
    def send_notification(rows)
      first_row = rows.sort_by{|row| Time.parse(row.datetime)}.reverse.first
      
      body = [
        Time.parse(first_row.datetime).strftime("%l:%M%P"),
        rows.sum(&:units).join(" "),
        first_row.location,
        first_row.incident_type,
        "http://j.mp/sea911"
      ].join(" - ")
      
      Pony.mail(:from => '911@z122.com', 
                :to => @recipients.join(', '), 
                :body => body,
                :via => :smtp, 
                :smtp => {
                  :host => 'smtp.gmail.com',
                  :port => '587',
                  :tls => true,
                  :user => '911@zachhale.com',
                  :password => 'P73375P73375',
                  :auth => :plain, # :plain, :login, :cram_md5, no auth by default
                })
    end
  end
end