require 'rubygems'
require 'extensions/symbol' unless :symbol.respond_to?(:to_proc)
require 'redis'
require 'time'

module NineOneOne
  class Runner
    @@sleep_interval = 60

    def initialize(notifiers)
      @notifiers = [*notifiers]
      @redis = Redis.new
    end

    def watch(meth, *args)
      loop do
        run(meth, *args)
        sleep @@sleep_interval
      end
    end

    def run(meth, *args)
      results = NineOneOne::Parser.new.send(meth, *args)

      base_key = "nineoneone:#{meth}"
      base_key << ":#{args.join(':')}" unless args.empty?

      # get the locations we've already notified about in the last 24 hours
      now = Time.now.to_i
      past = 14400 # 4 hours
      already_notified = @redis.zrangebyscore(base_key, now - past, now) || []

      # throw out ones we've already flagged
      results.reject! { |location, rows| already_notified.include?(location.sub(' ','-')) }

      # notify for new ones
      results.each do |location, rows|
        puts "#{Time.now.strftime("%l:%M%P")}: #{location} # => #{rows.sum(&:units).length}"
        send_notification(rows)
        @redis.zadd(base_key, Time.now.to_i, location.sub(' ','-'))
      end
    end

  private

    # 12:57am - E11 E37 M32 - 9422 24th Av SW - Medic Response, 7 per Rule
    def send_notification(rows)
      first_row = rows.sort_by(&:datetime).first
      units = rows.sum(&:units).uniq

      body = [
        first_row.datetime.strftime("%l:%M%P"),
        first_row.incident_type,
        first_row.location,
        "#{units.length}: #{units.sort.join(" ")}",
      ].join(" - ")

      @notifiers.each do |notifier|
        notifier.notify(body)
      end
    end
  end
end